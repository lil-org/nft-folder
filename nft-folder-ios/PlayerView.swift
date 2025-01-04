// ∅ 2025 lil org

import SwiftUI

struct PlayerWindowConfig: Hashable, Codable, Identifiable {
    var id = UUID()
    var initialItemId: String?
}

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var playerModel: PlayerModel
    private var config: PlayerWindowConfig
    
    init(config: PlayerWindowConfig) {
        self.config = config
        self.playerModel = PlayerModel(specificCollectionId: config.initialItemId, notTokenId: nil)
    }
    
    var body: some View {
        ZStack {
            MobileWebView(htmlString: playerModel.currentToken.html)
                .edgesIgnoringSafeArea(.all)

            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Images.close
                            .frame(width: 32, height: 32)
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack(spacing: 20) {
                    Button(action: {
                        DispatchQueue.main.async { playerModel.goBack() }
                    }) {
                        Images.back
                            .frame(width: 32, height: 32)
                            .padding(16)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Button(action: {
                        DispatchQueue.main.async { playerModel.goForward() }
                    }) {
                        Images.forward
                            .frame(width: 32, height: 32)
                            .padding(16)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Button(action: {
                        DispatchQueue.main.async { playerModel.changeCollection() }
                    }) {
                        Images.changeCollection
                            .frame(width: 32, height: 32)
                            .padding(16)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Button(action: {
                        DispatchQueue.main.async { playerModel.showingInfoPopover.toggle() }
                    }) {
                        Images.info
                            .frame(width: 32, height: 32)
                            .padding(16)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }.popover(isPresented: Binding(
                        get: { playerModel.showingInfoPopover },
                        set: { newValue in
                            DispatchQueue.main.async {
                                playerModel.showingInfoPopover = newValue
                            }
                        }
                    ), attachmentAnchor: .point(.top), arrowEdge: .top, content: {
                        infoPopoverView()
                    })
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func viewOnWeb() {
        if let url = playerModel.currentToken.url {
            UIApplication.shared.open(url)
        }
    }
    
    private func infoPopoverView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(playerModel.currentToken.displayName)
            Divider()
            Button(Strings.viewOnBlockscout, action: viewOnWeb)
            if let instructions = playerModel.currentToken.instructions {
                Divider()
                Text(instructions).font(.body)
            }
        }
        .padding().frame(width: 230)
    }
    
}
