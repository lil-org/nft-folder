// ∅ nft-folder 2024

import Cocoa

struct FolderIcon {
    
    static func set(for wallet: WatchOnlyWallet) {
        AvatarService.getAvatar(wallet: wallet) { _ in }
    }
    
}
