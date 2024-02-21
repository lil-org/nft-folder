// ∅ nft-folder-macos 2024

import Cocoa

struct FolderIcon {
    
    static func set(for wallet: WatchOnlyWallet) {
        guard let folderURL = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        setBlockies(for: wallet, folderURL: folderURL)
        AvatarService.getAvatar(wallet: wallet) { avatar in
            DispatchQueue.main.async {
                NSWorkspace.shared.setIcon(avatar, forFile: folderURL.path, options: [])
            }
        }
    }
    
    static private func setBlockies(for wallet: WatchOnlyWallet, folderURL: URL) {
        DispatchQueue.main.async {
            if let image = Blockies(seed: wallet.address.lowercased()).createImage() {
                NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: [])
            }
        }
    }
    
}
