// ∅ nft-folder 2024

import SwiftUI

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
