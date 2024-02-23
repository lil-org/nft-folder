// ∅ nft-folder-macos 2024

import Cocoa

struct FolderIcon {
    
    static func set(for wallet: WatchOnlyWallet) {
        guard let folderURL = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        
        DispatchQueue.main.async {
            if let image = Blockies(seed: wallet.address.lowercased()).createImage() {
                NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: [])
            }
        }
        
        AvatarService.getAvatar(wallet: wallet) { _ in }
    }
    
}
