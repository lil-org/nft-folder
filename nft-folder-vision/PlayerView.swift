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
        Text(playerModel.currentToken.displayName)
    }
}
