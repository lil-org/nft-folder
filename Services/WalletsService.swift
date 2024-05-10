// ∅ nft-folder 2024

import Foundation

struct WalletsService {
    
    enum WalletsServiceError: Error {
        case notAnAddress
    }
    
    private init() {}
    static let shared = WalletsService()
    private let urlSession = URLSession.shared
    private let fileManager = FileManager.default
    
    var wallets: [WatchOnlyWallet] {
        return SharedDefaults.watchWallets.reversed()
    }
    
    func getWalletsSections() -> [WalletsSection] {
        var sections = [WalletsSection]()
        
        var watchWallets = [WatchOnlyWallet]()
        var collections = [WatchOnlyWallet]()
        
        for wallet in wallets {
            if wallet.collections != nil {
                collections.append(wallet)
            } else {
                watchWallets.append(wallet)
            }
        }
        
        if !watchWallets.isEmpty {
            sections.append(WalletsSection(items: watchWallets, kind: .watchWallets))
        }
        
        if !collections.isEmpty {
            sections.append(WalletsSection(items: collections, kind: .collections))
        }
        
        return sections
    }
    
    func updateWithWallets(_ wallets: [WatchOnlyWallet]) {
        SharedDefaults.watchWallets = wallets.reversed()
    }
    
    func addWallet(_ wallet: WatchOnlyWallet) {
        SharedDefaults.addWallet(wallet)
        checkIfCollection(wallet: wallet)
    }
    
    func removeWallet(_ wallet: WatchOnlyWallet) {
        SharedDefaults.removeWallet(wallet)
    }
    
    func removeWallet(address: String) {
        if let toRemove = wallets.first(where: { $0.address == address }) {
            removeWallet(toRemove)
        }
    }
    
    func resolveENS(_ input: String, completion: @escaping (Result<EnsResponse, WalletsServiceError>) -> Void) {
        guard isEthAddress(input),
              let path = input.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.ensideas.com/ens/resolve/\(path)") else {
            completion(.failure(.notAnAddress))
            return
        }
        let dataTask = urlSession.dataTask(with: URLRequest(url: url)) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if error == nil, (200...299).contains(statusCode), let data = data, let response = try? JSONDecoder().decode(EnsResponse.self, from: data) {
                DispatchQueue.main.async { completion(.success(response)) }
            } else {
                DispatchQueue.main.async { completion(.failure(.notAnAddress)) }
            }
        }
        dataTask.resume()
    }
    
    func wallet(folderName: String) -> WatchOnlyWallet? {
        return wallets.first(where: { $0.folderDisplayName == folderName })
    }
    
    func hasWallet(folderName: String) -> Bool {
        return SharedDefaults.hasWallet(folderName: folderName)
    }
    
    func isEthAddress(_ input: String) -> Bool {
        if input.hasSuffix(".eth") { return true }
        guard input.hasPrefix("0x") && input.count == 42 else { return false }
        let hexSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        let addressSet = CharacterSet(charactersIn: String(input.dropFirst(2)))
        return hexSet.isSuperset(of: addressSet)
    }
    
    func checkFoldersForNewWalletsAndRemovedWallets(onNewWallet: @escaping (WatchOnlyWallet) -> Void) -> [WatchOnlyWallet] {
        guard let path = URL.nftDirectory?.path, let files = try? fileManager.contentsOfDirectory(atPath: path) else { return [] }
        var knownWallets = Set(wallets)
        for name in files {
            if let known = knownWallets.first(where: { $0.folderDisplayName == name }) {
                knownWallets.remove(known)
            }
            if isEthAddress(name) && !hasWallet(folderName: name) {
                resolveENS(name) { result in
                    switch result {
                    case .success(let response):
                        let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar, collections: nil)
                        self.addWallet(wallet)
                        renameFolder(path: path, name: name, wallet: wallet)
                        FolderIcon.set(for: wallet)
                        onNewWallet(wallet)
                    case .failure:
                        return
                    }
                }
            }
        }
        
        for remaining in knownWallets {
            removeWallet(address: remaining.address)
        }
        return Array(knownWallets)
    }
    
    func checkIfCollection(wallet: WatchOnlyWallet) {
        guard let path = URL.nftDirectory?.path else { return }
        ZoraApi.checkIfCollection(address: wallet.address) { response in
            if let responseCollections = response?.collections?.nodes {
                let collections = responseCollections.compactMap { collectionNode in
                    if let network = Network.withName(collectionNode.networkInfo.network) {
                        return CollectionInfo(name: collectionNode.name, network: network)
                    } else {
                        return nil
                    }
                }
                
                guard var collectionName = collections.first?.name else { return }
                if hasWallet(folderName: collectionName) {
                    collectionName += " " + wallet.address.suffix(4)
                }
                
                let updatedWallet = WatchOnlyWallet(address: wallet.address, name: collectionName, avatar: wallet.avatar, collections: collections)
                DispatchQueue.main.async {
                    var walletsUpdate = wallets
                    if let index = walletsUpdate.firstIndex(where: { $0.address == updatedWallet.address }) {
                        renameFolder(path: path, name: wallet.folderDisplayName, wallet: updatedWallet)
                        walletsUpdate[index] = updatedWallet
                        updateWithWallets(walletsUpdate)
                        AllDownloadsManager.shared.downloadCollections(collectionsWallet: updatedWallet, initialWallet: wallet)
                        NotificationCenter.default.post(name: .walletsUpdate, object: nil)
                    }
                }
            }
        }
    }
    
    private func renameFolder(path: String, name: String, wallet: WatchOnlyWallet) {
        let old = path + "/" + name
        let new = path + "/" + wallet.folderDisplayName
        do {
            try self.fileManager.moveItem(atPath: old, toPath: new)
        } catch {
            if self.fileManager.fileExists(atPath: new) == true {
                try? self.fileManager.removeItem(atPath: old)
            }
        }
    }
    
}
