// ∅ nft-folder 2024

import SwiftUI

struct TvPlayerView: View {
    
    @ObservedObject private var playerModel: PlayerModel
    
    init(initialItemId: String?) {
        self.playerModel = PlayerModel(specificCollectionId: initialItemId, notTokenId: nil)
    }
    
    var body: some View {
        TvHtmlView(htmlString: playerModel.currentToken.html)
    }
    
    private func infoPopoverView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(playerModel.currentToken.displayName)
            Divider()
            if let instructions = playerModel.currentToken.instructions {
                Divider()
                Text(instructions).font(.body)
            }
        }
        .padding().frame(width: 230)
    }
    
}
