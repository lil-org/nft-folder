// nft-folder-macos 2023 ethistanbul

import Foundation

struct Defaults {
    
    private static let userDefaults = UserDefaults(suiteName: "group.org.lil.nft-folder")!

    static func removeWallet(_ wallet: WatchOnlyWallet) {
        watchWallets.removeAll(where: { $0.address == wallet.address })
    }
    
    static func addWallet(_ wallet: WatchOnlyWallet) {
        guard !watchWallets.contains(where: { $0.address == wallet.address }) else { return }
        watchWallets += [wallet]
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
