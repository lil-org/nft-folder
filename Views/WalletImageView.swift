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
                RandomGradientShape(address: wallet.address)
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

struct RandomGradientShape: View {
    let address: String
    
    var body: some View {
        let colors = generateColors(from: address)
        let gradient = LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
        return Rectangle().fill(gradient)
    }
    
    func generateColors(from address: String) -> [Color] {
        let hash = simpleHash(address)
        return [
            Color(red: Double((hash & 0xFF)) / 255.0, green: Double((hash >> 8 & 0xFF)) / 255.0, blue: Double((hash >> 16 & 0xFF)) / 255.0),
            Color(red: Double((hash >> 24 & 0xFF)) / 255.0, green: Double((hash >> 32 & 0xFF)) / 255.0, blue: Double((hash >> 40 & 0xFF)) / 255.0)
        ]
    }
    
    func simpleHash(_ input: String) -> UInt64 {
        var hash: UInt64 = 0
        for char in input.utf8 {
            hash = (hash &* 31 &+ UInt64(char)) & UInt64.max
        }
        return hash
    }
}
