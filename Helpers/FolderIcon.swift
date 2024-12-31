// ∅ 2025 lil org

import Cocoa

struct FolderIcon {
    
    static func set(for wallet: WatchOnlyWallet) {
        AvatarService.getAvatar(wallet: wallet) { image in
            AvatarService.makeSureAvatarIsOnDisk(wallet: wallet, image: image)
        }
    }
    
}
