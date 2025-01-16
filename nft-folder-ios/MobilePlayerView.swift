// ∅ 2025 lil org

import SwiftUI

struct MobilePlayerConfig: Hashable, Codable, Identifiable {
    var id = UUID()
    var initialItemId: String?
    var specificToken: GeneratedToken?
}

private let doNotShowInstructionsTmp = true

struct MobilePlayerView: View {
    
    private let initialConfig: MobilePlayerConfig
    private let dismiss: () -> Void
    
    @State private var showControls = false
    @State private var isAllowedToHideStatusBar = false
    @State private var currentToken = GeneratedToken.empty
    @State private var currentCoordinate = PlayerCoordinate(x: 0, y: 0)
    
    init(config: MobilePlayerConfig, dismiss: @escaping () -> Void) {
        self.initialConfig = config
        self.dismiss = dismiss
    }
    
    private func makeCircularImageView(image: Image) -> some View {
        image
            .frame(width: 23, height: 23)
            .padding(10)
            .background(.thinMaterial)
            .clipShape(Circle())
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            FourDirectionalPlayerContainerView(initialConfig: initialConfig, onCoordinateUpdate: { newCoordinate in
                currentCoordinate = newCoordinate
                currentToken = MobilePlaybackController.shared.getToken(uuid: initialConfig.id, coordinate: newCoordinate)
            }).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showControls.toggle()
                }
                .onLongPressGesture {
                    showControls.toggle()
                }
                .statusBar(hidden: isAllowedToHideStatusBar && !showControls)
            
            if showControls {
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            makeCircularImageView(image: Images.close)
                        }
                        .padding()
                        Spacer()
                        Menu {
                            if !doNotShowInstructionsTmp, let instructions = currentToken.instructions {
                                Text(instructions)
                            }
                            Button(Strings.viewOnBlockscout, action: viewOnWeb)
                            Text(currentToken.displayName)
                        } label: {
                            makeCircularImageView(image: Images.info)
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
                            makeCircularImageView(image: Images.back)
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                        Button(action: {
                            goDown()
                        }) {
                            makeCircularImageView(image: Images.forward)
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                        Button(action: {
                            goBack()
                        }) {
                            makeCircularImageView(image: Images.up)
                        }
                        .keyboardShortcut(.upArrow, modifiers: [])
                        Button(action: {
                            goForward()
                        }) {
                            makeCircularImageView(image: Images.down)
                        }
                        .keyboardShortcut(.downArrow, modifiers: [])
                        Button(action: {
                            startPip()
                        }) {
                            makeCircularImageView(image: Images.pip)
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
                if token.id != currentToken.id {
                    let sameCollection = token.fullCollectionId == currentToken.fullCollectionId
                    DispatchQueue.main.async {
                        MobilePlaybackController.shared.showNewToken(displayId: initialConfig.id,
                                                                     token: token,
                                                                     sameCollection: sameCollection,
                                                                     coordinate: currentCoordinate)
                    }
                }
            }
        }
    }
    
    private func goForward() {
        MobilePlaybackController.shared.goForward(uuid: initialConfig.id)
    }
    
    private func goBack() {
        MobilePlaybackController.shared.goBack(uuid: initialConfig.id)
    }
    
    private func goUp() {
        MobilePlaybackController.shared.goUp(uuid: initialConfig.id)
    }
    
    private func goDown() {
        MobilePlaybackController.shared.goDown(uuid: initialConfig.id)
    }
    
    private func viewOnWeb() {
        if let url = currentToken.url {
            UIApplication.shared.open(url)
        }
    }
    
    private func startPip() {
        NotificationCenter.default.post(name: Notification.Name.togglePip, object: currentToken)
    }
    
}
