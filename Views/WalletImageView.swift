// ∅ nft-folder 2024

import SwiftUI
import Combine

struct WalletImageView: View {
    
    @State private var windowIsFocused: Bool = true
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
                RandomGradientShape(address: wallet.id)
            }
        }
        .overlay(
            Group {
                if !windowIsFocused {
                    FirstMouseView()
                }
            }
        )
        .onChange(of: wallet) { newWallet in
            avatarLoader.loadAvatar(wallet: newWallet)
        }.onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            windowIsFocused = true
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didResignActiveNotification)) { _ in
            windowIsFocused = false
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.didUpdateWalletAvatar)) { notification in
            if avatarLoader.avatar == nil && wallet.id == notification.object as? String {
                avatarLoader.loadAvatar(wallet: wallet)
            }
        }
    }
}

private class AvatarLoader: ObservableObject {
    @Published var avatar: NSImage?
    
    init(wallet: WatchOnlyWallet) {
        loadAvatar(wallet: wallet)
    }
    
    func loadAvatar(wallet: WatchOnlyWallet) {
        avatar = AvatarService.getAvatarImmediatelly(wallet: wallet)
        if avatar == nil {
            AvatarService.getAvatar(wallet: wallet) { image in
                self.avatar = image
            }
        }
    }
}
