// ∅ nft-folder 2024

import SwiftUI
import TVUIKit

struct TvPlayerView: View {
    
    @ObservedObject private var playerModel: PlayerModel
    @State private var showInfoPopover = false
    
    init(initialItemId: String?) {
        self.playerModel = PlayerModel(specificCollectionId: initialItemId, notTokenId: nil)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            GeneratedTokenView(contentString: playerModel.currentToken.html).edgesIgnoringSafeArea(.all)
                .onAppear() {
                    if !playerModel.history.isEmpty {
                        playerModel.goForward()
                    }
                }
                .focusable()
                .onMoveCommand { direction in
                    switch direction {
                    case .left:
                        DispatchQueue.main.async { playerModel.goBack() }
                    case .right:
                        DispatchQueue.main.async { playerModel.goForward() }
                    case .up:
                        DispatchQueue.main.async { playerModel.goBack() }
                    case .down:
                        DispatchQueue.main.async { playerModel.changeCollection() }
                    default:
                        break
                    }
                }
                .onPlayPauseCommand {
                    showInfoPopover.toggle()
                }
            
            if showInfoPopover {
                infoPopoverView()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(15)
                    .padding()
            }
        }
    }
    
    private func infoPopoverView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(playerModel.currentToken.displayName)
        }
        .padding().frame(minWidth: 250)
    }
    
}
