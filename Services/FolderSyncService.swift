// ∅ nft-folder 2024

import Cocoa

struct FolderSyncService {
    
    static func pushCustomFolders(wallet: WatchOnlyWallet) {
        showConfirmationAlert(wallet: wallet)
    }
    
    private static func showConfirmationAlert(wallet: WatchOnlyWallet) {
        let alert = NSAlert()
        alert.messageText = Strings.pushCustomFolders + "?"
        alert.informativeText = wallet.folderDisplayName
        alert.alertStyle = .informational
        alert.addButton(withTitle: Strings.ok)
        alert.addButton(withTitle: Strings.cancel)
        alert.buttons.last?.keyEquivalent = "\u{1b}"
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            // TODO: check if folders were changed
            // TODO: upload to ipfs
            // TODO: redirect to hash uploader page
            if let galleryURL = NftGallery.opensea.url(wallet: wallet) {
                DispatchQueue.main.async { NSWorkspace.shared.open(galleryURL) }
            }
        default:
            break
        }
    }
    
}
