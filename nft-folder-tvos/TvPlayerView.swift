// ∅ 2025 lil org

import SwiftUI
import TVUIKit
import CoreImage.CIFilterBuiltins

struct TvPlayerView: View {
    
    @ObservedObject private var playerModel: PlayerModel
    @State private var showInfoPopover = !Defaults.preferresInfoPopoverHidden
    @State private var showTutorial = false
    
    init(initialItemId: String?) {
        self.playerModel = PlayerModel(specificCollectionId: initialItemId, notTokenId: nil)
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            GeneratedTokenView(contentString: playerModel.currentToken.html, fallbackURL: fallbackURL()).edgesIgnoringSafeArea(.all)
                .onAppear() {
                    if let initialSpecific = playerModel.specificCollectionId, initialSpecific != playerModel.currentToken.fullCollectionId {
                        playerModel.showInitialCollection()
                    } else if !playerModel.history.isEmpty {
                        playerModel.goForward()
                    }
                    if !Defaults.didShowTvPlayerTutorial {
                        showTutorial = true
                        showInfoPopover = true
                        Defaults.didShowTvPlayerTutorial = true
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
                    showTutorial = false
                    Defaults.preferresInfoPopoverHidden = showInfoPopover
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
    
    private func fallbackURL() -> URL? {
        return URL(string: "https://media-proxy.artblocks.io/\(playerModel.currentToken.address)/\(playerModel.currentToken.id).png")
    }
    
    private func infoPopoverView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(uiImage: generateQRCode(playerModel.currentToken.url?.absoluteString ?? ""))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            Text(playerModel.currentToken.displayName)
            if showTutorial {
                Divider()
                Text("↔️↕️ navigate")
                Text("⏯️ toggle info")
            }
        }
        .padding().frame(width: 230)
    }
    
    private func generateQRCode(_ string: String) -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage, let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return UIImage(cgImage: cgimg)
        } else {
            return UIImage()
        }
    }
    
}
