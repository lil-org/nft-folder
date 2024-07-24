// ∅ nft-folder 2024

import SwiftUI

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
