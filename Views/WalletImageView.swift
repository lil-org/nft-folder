// ∅ nft-folder 2024

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
                    .scaledToFill()
                    .background(Color.white)
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
