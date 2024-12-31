// ∅ 2025 lil org

import Foundation

struct SharedDefaults {
    
    private static let userDefaults = UserDefaults(suiteName: "8DXC3N7E7P.group.org.lil.wallet")!

    static func eraseAllContent() {
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    static func performCleanup(version: Int) {
        if version < 1 {
            userDefaults.keepOnly(keys: ["watch-wallets"])
        }
    }
    
    static func hasWallet(folderName: String) -> Bool {
        return watchWallets.contains(where: { $0.folderDisplayName == folderName })
    }
    
    static func removeWallet(_ wallet: WatchOnlyWallet) {
        watchWallets.removeAll(where: { $0.id == wallet.id })
    }
    
    static func addWallet(_ wallet: WatchOnlyWallet) {
        guard !watchWallets.contains(where: { $0.id == wallet.id }) else { return }
        watchWallets += [wallet]
        NotificationCenter.default.post(name: .walletsUpdate, object: nil)
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
    
    static var downloadsInProgress: Bool {
        get {
            userDefaults.bool(forKey: "downloadsInProgress")
        }
        set {
            userDefaults.set(newValue, forKey: "downloadsInProgress")
        }
    }
    
}
