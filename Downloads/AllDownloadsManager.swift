// ∅ nft-folder-macos 2024

import Foundation

class AllDownloadsManager {
 
    static let shared = AllDownloadsManager()
    private init() {}
    
    private let walletsService = WalletsService.shared
    private let fileManager = FileManager.default
        
    func syncNewWallet(wallet: WatchOnlyWallet) {
        WalletDownloader.shared.study(wallet: wallet) // TODO: make if fit within ongoing downloads
    }
    
    // TODO: clean up, refactor
    func checkFolders() {
        guard let path = URL.nftDirectory?.path, let files = try? fileManager.contentsOfDirectory(atPath: path) else { return }
        var knownWallets = Set(walletsService.wallets)
        for name in files {
            if let known = knownWallets.first(where: { $0.folderDisplayName == name }) {
                knownWallets.remove(known)
            }
            if walletsService.isEthAddress(name) && !walletsService.hasWallet(folderName: name) {
                walletsService.resolveENS(name) { [weak self] result in
                    switch result {
                    case .success(let response):
                        let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar)
                        self?.walletsService.addWallet(wallet)
                        FolderIcon.set(for: wallet)
                        let old = path + "/" + name
                        let new = path + "/" + wallet.folderDisplayName
                        do {
                            try self?.fileManager.moveItem(atPath: old, toPath: new)
                        } catch {
                            if self?.fileManager.fileExists(atPath: new) == true {
                                try? self?.fileManager.removeItem(atPath: old)
                            }
                        }
                        WalletDownloader.shared.study(wallet: wallet)
                    case .failure:
                        return
                    }
                }
            }
        }
        
        for remaining in knownWallets {
            // TODO: stop downloads for that wallet as well
            walletsService.removeWallet(address: remaining.address)
        }
    }
    
    func prioritizeDownloads(mbAddressFolderName: String?) {
        // TODO: implement
    }
    
    // TODO: always check for running syncs before starting new ones
    func syncOnUserRequestIfNeeded() {
        for wallet in walletsService.wallets {
            WalletDownloader.shared.study(wallet: wallet)
        }
    }
    
}
