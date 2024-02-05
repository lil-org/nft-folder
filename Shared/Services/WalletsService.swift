// ∅ nft-folder-macos 2024

import Foundation

struct WalletsService {
    
    enum WalletsServiceError: Error {
        case notAnAddress
    }
    
    private init() {}
    static let shared = WalletsService()
    private let urlSession = URLSession.shared
    
    var wallets: [WatchOnlyWallet] {
        return Defaults.watchWallets
    }
    
    func addWallet(_ wallet: WatchOnlyWallet) {
        Defaults.addWallet(wallet)
    }
    
    func removeWallet(_ wallet: WatchOnlyWallet) {
        Defaults.removeWallet(wallet)
    }
    
    func removeWallet(address: String) {
        if let toRemove = wallets.first(where: { $0.address == address }) {
            removeWallet(toRemove)
        }
    }
    
    func resolveENS(_ input: String, completion: @escaping (Result<ENSResponse, WalletsServiceError>) -> Void) {
        guard isEthAddress(input),
              let path = input.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.ensideas.com/ens/resolve/\(path)") else {
            completion(.failure(.notAnAddress))
            return
        }
        let dataTask = urlSession.dataTask(with: URLRequest(url: url)) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if error == nil, (200...299).contains(statusCode), let data = data, let response = try? JSONDecoder().decode(ENSResponse.self, from: data) {
                DispatchQueue.main.async { completion(.success(response)) }
            } else {
                DispatchQueue.main.async { completion(.failure(.notAnAddress)) }
            }
        }
        dataTask.resume()
    }
    
    func hasWallet(folderName: String) -> Bool {
        return wallets.contains(where: { $0.folderDisplayName == folderName })
    }
    
    func isEthAddress(_ input: String) -> Bool {
        if input.hasSuffix(".eth") { return true }
        guard input.hasPrefix("0x") && input.count == 42 else { return false }
        let hexSet = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        let addressSet = CharacterSet(charactersIn: String(input.dropFirst(2)))
        return hexSet.isSuperset(of: addressSet)
    }
    
}

private struct Defaults {
    
    private static let userDefaults = UserDefaults(suiteName: "group.org.lil.nft-folder")!

    static func removeWallet(_ wallet: WatchOnlyWallet) {
        watchWallets.removeAll(where: { $0.address == wallet.address })
    }
    
    static func addWallet(_ wallet: WatchOnlyWallet) {
        guard !watchWallets.contains(where: { $0.address == wallet.address }) else { return }
        watchWallets += [wallet]
        NotificationCenter.default.post(name: Notification.Name("walletsUpdate"), object: nil)
        _ = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: true)
    }
    
    static var watchWallets: [WatchOnlyWallet] {
        get {
            let stored = userDefaults.value(forKey: "watch-wallets")
            return WatchOnlyWallet.arrayFrom(stored) ?? []
        }
        set {
            let dicts = newValue.compactMap { $0.toDictionary() }
            userDefaults.set(dicts, forKey: "watch-wallets")
        }
    }
    
}

