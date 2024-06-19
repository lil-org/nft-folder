// ∅ nft-folder 2024

import SwiftUI
import Combine

struct WalletImageView: View {
    
    @StateObject private var avatarLoader: AvatarLoader
    let wallet: WatchOnlyWallet
    
    init(wallet: WatchOnlyWallet) {
        self.wallet = wallet
        _avatarLoader = StateObject(wrappedValue: AvatarLoader(wallet: wallet))
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
        .onChange(of: wallet) { newWallet in
            avatarLoader.loadAvatar(wallet: newWallet)
        }
    }
}

private class AvatarLoader: ObservableObject {
    @Published var avatar: NSImage?
    
    init(wallet: WatchOnlyWallet) {
        loadAvatar(wallet: wallet)
    }
    
    func loadAvatar(wallet: WatchOnlyWallet) {
        avatar = nil
        // TODO: access quicker, access directly
        AvatarService.getAvatar(wallet: wallet) { image in
            self.avatar = image
        }
    }
}
