// ∅ 2025 lil org

import SwiftUI

struct MobilePlayerConfig: Hashable, Codable, Identifiable {
    var id = UUID()
    var initialItemId: String?
    var specificToken: GeneratedToken?
}

private let doNotShowInstructionsTmp = true
private let buttonIconSize: CGFloat = 23
private let buttonPadding: CGFloat = 10

struct MobilePlayerView: View {
    @ObservedObject private var playerModel: PlayerModel
    @Binding var config: MobilePlayerConfig?
    @State private var showControls = false
    @State private var isAllowedToHideStatusBar = false
    
    init(config: Binding<MobilePlayerConfig?>) {
        if let c = config.wrappedValue {
            if let token = c.specificToken {
                self.playerModel = PlayerModel(token: token)
            } else {
                self.playerModel = PlayerModel(specificCollectionId: c.initialItemId, notTokenId: nil)
            }
        } else {
            self.playerModel = PlayerModel(specificCollectionId: nil, notTokenId: nil)
        }
        self._config = config
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            FourDirectionalPlayerContainerView()
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showControls.toggle()
                }
                .statusBar(hidden: isAllowedToHideStatusBar && !showControls)
            
            if showControls {
                VStack {
                    HStack {
                        Button(action: {
                            config = nil
                        }) {
                            Images.close
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding()
                        Spacer()
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
                        .padding()
                    }
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: {
                            goUp()
                        }) {
                            Images.up
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            goDown()
                        }) {
                            Images.down
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            goBack()
                        }) {
                            Images.back
                                .frame(width: buttonIconSize, height: buttonIconSize)
                                .padding(buttonPadding)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        Button(action: {
                            goForward()
                        }) {
                            Images.forward
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
        .onAppear {
            if !isAllowedToHideStatusBar {
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let window = scene?.windows.first
                let topSafeArea = window?.safeAreaInsets.top ?? 0
                if topSafeArea < 44 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(200)) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isAllowedToHideStatusBar = true
                        }
                    }
                } else {
                    isAllowedToHideStatusBar = true
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.restoreMinimizedPip)) { notification in
            if let token = notification.object as? GeneratedToken {
                if token.id != playerModel.currentToken.id {
                    DispatchQueue.main.async { playerModel.showNewToken(token) }
                }
            }
        }
    }
    
    private func goForward() {
        // TODO: remake
        DispatchQueue.main.async { playerModel.goForward() }
    }
    
    private func goBack() {
        // TODO: remake
        DispatchQueue.main.async { playerModel.goBack() }
    }
    
    private func goUp() {
        // TODO: remake
        DispatchQueue.main.async { playerModel.goBack() }
    }
    
    private func goDown() {
        // TODO: remake
        DispatchQueue.main.async { playerModel.changeCollection() }
    }
    
    private func viewOnWeb() {
        if let url = playerModel.currentToken.url {
            UIApplication.shared.open(url)
        }
    }
    
    private func startPip() {
        NotificationCenter.default.post(name: Notification.Name.togglePip, object: playerModel.currentToken)
    }
    
}
