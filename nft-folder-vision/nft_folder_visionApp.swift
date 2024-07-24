// ∅ nft-folder 2024

import SwiftUI

@main
struct nft_folder_visionApp: App {
    var body: some Scene {
        WindowGroup(id: "suggested-items") {
            ContentView()
        }
        
        WindowGroup(id: "player") {
            PlayerView()
        }
    }
}

struct ContentView: View {
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack {
            Button("Play", action: {
                play()
            })
        }
        .padding()
    }
    
    private func play() {
        openWindow(id: "player")
    }
    
}


struct PlayerView: View {
    
    var body: some View {
        Text("playing...").font(.headline)
    }
    
}
