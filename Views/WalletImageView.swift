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
                GeometryReader { geometry in
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .clipped()
                        .background(Color.white)
                }
            } else {
                Rectangle().foregroundColor(wallet.placeholderColor)
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
            self.avatar = image
        }
    }
}
