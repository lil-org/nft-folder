// ∅ nft-folder-macos 2024

import Foundation

class AllDownloadsManager {
 
    static let shared = AllDownloadsManager()
    private init() {}
    
    private let walletsService = WalletsService.shared
        
    func start() {
        // TODO: implement
        // TODO: start refresh maybe
        // TODO: check folders after launch — maybe they changed
        // TODO: maybe there are already some downloads running — started with explicit launch request
    }
    
    func syncNewWallet(wallet: WatchOnlyWallet) {
        // TODO: make it fit within ongoing downloads
        // TODO: make sure not to start twice for any wallet
        WalletDownloader.shared.study(wallet: wallet)
    }
    
    func prioritizeDownloads(wallet: WatchOnlyWallet) {
        // TODO: make it fit within ongoing downloads
        // TODO: make sure not to start twice for any wallet
        WalletDownloader.shared.study(wallet: wallet)
    }
    
    func walletsFoldersChanged() {
        let removedWallets = walletsService.checkFoldersForNewWalletsAndRemovedWallets { newWallet in
            self.syncNewWallet(wallet: newWallet)
        }
        for removedWallet in removedWallets {
            stopDownloads(wallet: removedWallet)
        }
    }
    
    func stopDownloads(wallet: WatchOnlyWallet) {
        // TODO: implement
    }
    
    func prioritizeDownloads(mbAddressFolderName: String?) {
        if let folderName = mbAddressFolderName, let wallet = walletsService.wallet(folderName: folderName) {
            // TODO: implement
        } else {
            // TODO: implement
        }
    }
    
    // TODO: always check for running syncs before starting new ones
    func syncOnUserRequestIfNeeded() {
        for wallet in walletsService.wallets {
            WalletDownloader.shared.study(wallet: wallet)
        }
    }
    
}
