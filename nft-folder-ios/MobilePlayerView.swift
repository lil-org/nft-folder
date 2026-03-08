// ∅ 2026 lil org

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
    private let buttonShapesEnabled = UIAccessibility.buttonShapesEnabled
    
    @State private var showControls = false
    @State private var isAllowedToHideStatusBar = false
    @State private var currentToken = GeneratedToken.empty
    @State private var currentCoordinate = PlayerCoordinate(x: 0, y: 0)
    @State private var dismissDragOffsetX: CGFloat = 0
    @State private var dismissDragOffsetY: CGFloat = 0
    @State private var dismissDragScale: CGFloat = 1
    @State private var dismissDragOpacity: CGFloat = 1
    @State private var isDismissingInteractively = false
    
    init(config: MobilePlayerConfig, dismiss: @escaping () -> Void) {
        self.initialConfig = config
        self.dismiss = dismiss
    }
    
    private func makeCircularImageView(image: Image) -> some View {
        image
            .frame(width: 23, height: 23)
            .padding(10)
            .background(.regularMaterial)
            .clipShape(Circle())
    }
    
    var body: some View {
        let dismissDragGesture = DragGesture(minimumDistance: 3)
            .onChanged { gesture in
                let vertical = gesture.translation.height
                let horizontal = abs(gesture.translation.width)
                if !isDismissingInteractively {
                    guard vertical > 0, vertical > horizontal * 0.8 else { return }
                    isDismissingInteractively = true
                }

                let clampedVertical = max(0, vertical)
                let progress = min(clampedVertical / 700, 1)
                dismissDragOffsetX = gesture.translation.width * 0.22
                dismissDragOffsetY = clampedVertical
                dismissDragScale = 1 - progress * 0.14
                dismissDragOpacity = 1 - progress * 0.35
            }
            .onEnded { _ in
                let dismissThreshold: CGFloat = 120
                guard isDismissingInteractively else { return }
                if dismissDragOffsetY > dismissThreshold {
                    withAnimation(.easeOut(duration: 0.18)) {
                        dismissDragOffsetX = 0
                        dismissDragOffsetY = UIScreen.main.bounds.height
                        dismissDragScale = 0.82
                        dismissDragOpacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(170)) {
                        dismiss()
                        updateExternalDisplayToken(GeneratedToken.empty)
                        dismissDragOffsetX = 0
                        dismissDragOffsetY = 0
                        dismissDragScale = 1
                        dismissDragOpacity = 1
                        isDismissingInteractively = false
                    }
                } else {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.85)) {
                        dismissDragOffsetX = 0
                        dismissDragOffsetY = 0
                        dismissDragScale = 1
                        dismissDragOpacity = 1
                        isDismissingInteractively = false
                    }
                }
            }

        ZStack {
            Color.black.opacity(dismissDragOpacity).edgesIgnoringSafeArea(.all)
            FourDirectionalPlayerContainerView(initialConfig: initialConfig, onCoordinateUpdate: { newCoordinate in
                DispatchQueue.main.async {
                    self.currentCoordinate = newCoordinate
                    self.currentToken = MobilePlaybackController.shared.getToken(uuid: initialConfig.id, coordinate: newCoordinate)
                    updateExternalDisplayToken(currentToken)
                }
                
            }, isHorizontalPagingEnabled: !isDismissingInteractively).edgesIgnoringSafeArea(.all)
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
                            updateExternalDisplayToken(GeneratedToken.empty)
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
                    HStack(spacing: buttonShapesEnabled ? nil : 20) {
                        Button(action: {
                            goBack()
                        }) {
                            makeCircularImageView(image: Images.back)
                        }
                        .keyboardShortcut(.leftArrow, modifiers: [])
                        Button(action: {
                            goForward()
                        }) {
                            makeCircularImageView(image: Images.forward)
                        }
                        .keyboardShortcut(.rightArrow, modifiers: [])
                        Button(action: {
                            changeCollection()
                        }) {
                            makeCircularImageView(image: Images.changeCollection)
                        }
                        Button(action: {
                            startPip()
                            Haptic.selectionChanged()
                        }) {
                            makeCircularImageView(image: Images.pip)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .scaleEffect(dismissDragScale, anchor: .top)
        .offset(x: dismissDragOffsetX, y: dismissDragOffsetY)
        .simultaneousGesture(dismissDragGesture)
        .onChange(of: isDismissingInteractively) { _, isDismissing in
            AutoReloadingWebView.setResizeReloadEnabled(!isDismissing)
        }
        .onDisappear {
            AutoReloadingWebView.setResizeReloadEnabled(true)
        }
        .onAppear {
            AutoReloadingWebView.setResizeReloadEnabled(true)
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

    private func changeCollection() {
        MobilePlaybackController.shared.changeCollection(uuid: initialConfig.id)
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
