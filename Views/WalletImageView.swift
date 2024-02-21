// ∅ nft-folder-macos 2024

import SwiftUI
import Combine

struct WalletImageView: View {
    
    @StateObject private var avatarLoader = AvatarLoader()
    let wallet: WatchOnlyWallet
    
    init(wallet: WatchOnlyWallet) {
        self.wallet = wallet
        _avatarLoader = StateObject(wrappedValue: AvatarLoader())
    }
    
    var body: some View {
        Group {
            if let nsImage = avatarLoader.avatar {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            } else {
                Image(nsImage: Blockies(seed: wallet.address.lowercased()).createImage() ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            }
        }
        .onAppear {
            avatarLoader.loadAvatar(wallet: wallet)
        }
    }
    
}

private class AvatarLoader: ObservableObject {
    @Published var avatar: NSImage?
    
    func loadAvatar(wallet: WatchOnlyWallet) {
        AvatarService.getAvatar(wallet: wallet) { image in
            DispatchQueue.main.async {
                self.avatar = image
            }
        }
    }
    
}
