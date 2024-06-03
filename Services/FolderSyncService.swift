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
            uploadFoldersToIpfsAndSaveOnchain(wallet: wallet)
        default:
            break
        }
    }
    
    private static func uploadFoldersToIpfsAndSaveOnchain(wallet: WatchOnlyWallet) {
        // TODO: check if folders were changed
        // TODO: create file properly
        guard let fileData = wallet.address.data(using: .utf8) else { return }
        IpfsUploader.upload(name: wallet.address, mimeType: "application/json", data: fileData) { cid in
            if let cid = cid, let url = URL(string: "https://zora.co/create?image=ipfs://\(cid)") {
                // TODO: open EAS url
                NSWorkspace.shared.open(url)
            } else {
                showErrorAlert()
            }
        }
    }
    
    private static func showErrorAlert() {
        let alert = NSAlert()
        alert.messageText = Strings.somethingWentWrong
        alert.alertStyle = .warning
        _ = alert.runModal()
    }
    
}
