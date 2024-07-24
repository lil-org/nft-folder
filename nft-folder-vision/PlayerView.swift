// ∅ nft-folder 2024

import SwiftUI

struct PlayerWindowConfig: Hashable, Codable, Identifiable {
    var id = UUID()
    var initialItemId: String?
}

struct PlayerView: View {
    
    @ObservedObject private var playerModel: PlayerModel
    private var config: PlayerWindowConfig
    
    init(config: PlayerWindowConfig) {
        self.config = config
        self.playerModel = PlayerModel(specificCollectionId: config.initialItemId, notTokenId: nil)
    }
    
    var body: some View {
        VStack {
            MobileWebView(htmlString: playerModel.currentToken.html)
            HStack {
                Button(action: {
                    DispatchQueue.main.async { playerModel.goBack() }
                }) {
                    Images.back
                }
                Button(action: {
                    DispatchQueue.main.async { playerModel.goForward() }
                }) {
                    Images.forward
                }
                Button(action: {
                    DispatchQueue.main.async { playerModel.changeCollection() }
                }) {
                    Images.changeCollection
                }
                Button(action: {
                    DispatchQueue.main.async { playerModel.showingInfoPopover.toggle() }
                }) {
                    Images.info
                }
            }
            .padding()
        }
    }
}
