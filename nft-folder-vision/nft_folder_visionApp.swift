// ∅ nft-folder 2024

import SwiftUI

struct WindowId {
    
    static let collections = "collections"
    static let player = "player"
    
}

struct Images {
    
}

@main
struct nft_folder_visionApp: App {
    var body: some Scene {
        WindowGroup(id: WindowId.collections) {
            CollectionsView()
        }
        
        WindowGroup(id: WindowId.player) {
            PlayerView()
        }
    }
}

struct CollectionsView: View {
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            Button(action: {
                play()
            }) {
                Images.shuffle
            }
        }
        .padding()
    }
    
    private func play() {
        openWindow(id: WindowId.player)
    }
    
}


struct PlayerView: View {
    
    var body: some View {
        Text("playing...").font(.headline)
    }
    
}
