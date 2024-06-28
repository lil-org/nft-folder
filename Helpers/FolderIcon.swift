// ∅ nft-folder 2024

import Cocoa

struct FolderIcon {
    
    static func set(for wallet: WatchOnlyWallet) {
        // TODO: make sure it writes on disk, not just returns cached value
        AvatarService.getAvatar(wallet: wallet) { _ in }
    }
    
}
