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
                RandomGradientShape(address: wallet.address)
            }
        }
        .onChange(of: wallet) { newWallet in
            avatarLoader.loadAvatar(wallet: newWallet)
        }
        .animation(nil, value: avatarLoader.avatar)
    }
}

private class AvatarLoader: ObservableObject {
    @Published var avatar: NSImage?
    
    init(wallet: WatchOnlyWallet) {
        loadAvatar(wallet: wallet)
    }
    
    func loadAvatar(wallet: WatchOnlyWallet) {
        // TODO: access quicker, access directly
        avatar = nil
        AvatarService.getAvatar(wallet: wallet) { image in
            self.avatar = image
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
