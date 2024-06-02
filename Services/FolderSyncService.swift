// ∅ nft-folder 2024

import Cocoa

struct FolderSyncService {
    
    static func pushCustomFolders(wallet: WatchOnlyWallet) {
        // TODO: implement
        
        // TODO: check if folders were changed
        // TODO: confirm it's yours wallet
        // TODO: upload to ipfs
        // TODO: redirect to hash uploader page
        if let galleryURL = NftGallery.opensea.url(wallet: wallet) {
            DispatchQueue.main.async { NSWorkspace.shared.open(galleryURL) }
        }
    }
    
}
