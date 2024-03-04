// ∅ nft-folder-macos 2024

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
    
    func addWallet(_ wallet: WatchOnlyWallet) {
        SharedDefaults.addWallet(wallet)
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
                        let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar)
                        self.addWallet(wallet)
                        let old = path + "/" + name
                        let new = path + "/" + wallet.folderDisplayName
                        do {
                            try self.fileManager.moveItem(atPath: old, toPath: new)
                        } catch {
                            if self.fileManager.fileExists(atPath: new) == true {
                                try? self.fileManager.removeItem(atPath: old)
                            }
                        }
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
    
}
