// ∅ 2025 lil org

import SwiftUI

struct MobilePlayerConfig: Hashable, Codable, Identifiable {
    var id = UUID()
    var initialItemId: String?
}

private let doNotShowInstructionsTmp = true
private let buttonIconSize: CGFloat = 23
private let buttonPadding: CGFloat = 10

struct MobilePlayerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var playerModel: PlayerModel
    private var config: MobilePlayerConfig
    @State private var showControls = false
    
    init(config: MobilePlayerConfig) {
        self.config = config
        self.playerModel = PlayerModel(specificCollectionId: config.initialItemId, notTokenId: nil)
    }
    
    var body: some View {
        ZStack {
            MobileWebView(htmlString: playerModel.currentToken.html)
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
                .contentShape(Rectangle())
                .onTapGesture {
                    showControls.toggle()
                }
                .statusBar(hidden: !showControls)

            if showControls {
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Images.close
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
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
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            DispatchQueue.main.async { playerModel.goForward() }
                        }) {
                            Images.forward
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            DispatchQueue.main.async { playerModel.changeCollection() }
                        }) {
                            Images.changeCollection
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Menu {
                            if !doNotShowInstructionsTmp, let instructions = playerModel.currentToken.instructions {
                                Text(instructions)
                            }
                            Button(Strings.viewOnBlockscout, action: viewOnWeb)
                            Text(playerModel.currentToken.displayName)
                        } label: {
                            Images.info
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            startPip()
                        }) {
                            Images.pip
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    private func viewOnWeb() {
        if let url = playerModel.currentToken.url {
            UIApplication.shared.open(url)
        }
    }
    
    private func startPip() {
        NotificationCenter.default.post(name: NSNotification.Name("togglePip"), object: playerModel.currentToken.html)
    }
    
}
