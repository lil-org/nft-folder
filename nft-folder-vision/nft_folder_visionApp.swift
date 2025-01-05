// ∅ 2025 lil org

import SwiftUI

@main
struct nft_folder_visionApp: App {
    var body: some Scene {
        WindowGroup(id: WindowId.collections) {
            VisionCollectionsView()
        }
        
        WindowGroup(for: VisionPlayerWindowConfig.self) { $config in
            if let config = config {
                VisionPlayerView(config: config).handlesExternalEvents(preferring: [], allowing: [])
            }
        }
    }
}
