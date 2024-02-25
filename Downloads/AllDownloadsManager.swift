// ∅ nft-folder-macos 2024

import Foundation

class AllDownloadsManager {
 
    enum Status {
        case downloading, notDownloading
    }
    
    private(set) var statuses = [WatchOnlyWallet: Status]()
    
    static let shared = AllDownloadsManager()
    private init() {}
    
    private let walletsService = WalletsService.shared
    private var walletDownloaders = [WatchOnlyWallet: WalletDownloader]()
    
    func start() {}
    
    func startDownloads(wallet: WatchOnlyWallet) {
        statuses[wallet] = .downloading
        let walletDownloader = WalletDownloader { [weak self] in
            DispatchQueue.main.async {
                self?.stopDownloads(wallet: wallet)
            }
        }
        walletDownloader.study(wallet: wallet)
        postStatusUpdateNotification()
        walletDownloaders[wallet] = walletDownloader
    }
    
    func stopDownloads(wallet: WatchOnlyWallet) {
        statuses.removeValue(forKey: wallet)
        walletDownloaders.removeValue(forKey: wallet)
        postStatusUpdateNotification()
    }
    
    func prioritizeDownloads(mbAddressFolderName: String?) {}
    
    func prioritizeDownloads(wallet: WatchOnlyWallet) {}
    
    func syncOnUserRequestIfNeeded() {}
    
    func checkFolders() {
        let removedWallets = walletsService.checkFoldersForNewWalletsAndRemovedWallets { newWallet in
            self.startDownloads(wallet: newWallet)
        }
        for removedWallet in removedWallets {
            stopDownloads(wallet: removedWallet)
        }
    }
    
    private func postStatusUpdateNotification() {
        NotificationCenter.default.post(name: .downloadsStatusUpdate, object: nil)
    }
    
}
