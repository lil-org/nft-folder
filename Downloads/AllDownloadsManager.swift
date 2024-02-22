// ∅ nft-folder-macos 2024

import Foundation

class AllDownloadsManager {
 
    enum Status {
        case downloading, notDownloading
    }
    
    static let shared = AllDownloadsManager()
    private init() {}
    
    private let walletsService = WalletsService.shared
    var statuses = [WatchOnlyWallet: Status]()
    
    func start() {}
    
    func startDownloads(wallet: WatchOnlyWallet) {
        statuses[wallet] = .downloading
        // TODO: make it fit within ongoing downloads
        // TODO: make sure not to start twice for any wallet
        WalletDownloader.shared.study(wallet: wallet)
        postStatusUpdateNotification()
    }
    
    func stopDownloads(wallet: WatchOnlyWallet) {
        statuses[wallet] = .notDownloading
        // TODO: implement
        postStatusUpdateNotification()
    }
    
    func walletsFoldersChanged() {
        let removedWallets = walletsService.checkFoldersForNewWalletsAndRemovedWallets { newWallet in
            self.startDownloads(wallet: newWallet)
        }
        for removedWallet in removedWallets {
            stopDownloads(wallet: removedWallet)
        }
    }
    
    func prioritizeDownloads(mbAddressFolderName: String?) {}
    
    func prioritizeDownloads(wallet: WatchOnlyWallet) {}
    
    func syncOnUserRequestIfNeeded() {}
    
    private func postStatusUpdateNotification() {
        NotificationCenter.default.post(name: .downloadsStatusUpdate, object: nil)
    }
    
}
