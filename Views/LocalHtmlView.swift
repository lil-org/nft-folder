// ∅ nft-folder 2024

import SwiftUI
import AppKit

struct LocalHtmlView: View {
    
    private var windowNumber = 0
    
    @State private var currentToken = TokenGenerator.generateRandomToken(specificCollectionId: nil, notCollectionId: nil, notTokenId: nil) ?? GeneratedToken(fullCollectionId: "", id: "", html: "", displayName: "", url: nil, instructions: nil)
    @State private var history = [GeneratedToken]()
    @State private var currentIndex = 0
    @State private var showingInfoAlert = false
    @State private var isFullscreen = false
    
    init(windowNumber: Int) {
        self.windowNumber = windowNumber
    }
    
    var body: some View {
        let toolbarButtonsColor = Color.gray
        DesktopWebView(htmlContent: currentToken.html)
            .onAppear {
                history.append(currentToken)
                updateFullscreenStatus()
            }
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity).background(.black)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: goBack) {
                        Images.back.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle())
                    .disabled(currentIndex <= 0)
                    .keyboardShortcut(.leftArrow, modifiers: [])
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: goForward) {
                        Images.forward.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle())
                    .keyboardShortcut(.rightArrow, modifiers: [])
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: changeCollection) {
                        Images.changeCollection.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle()).keyboardShortcut(.space, modifiers: [])
                }
                ToolbarItem(placement: .principal) {
                    Text(currentToken.displayName).font(.callout).foregroundStyle(toolbarButtonsColor)
                }
                ToolbarItemGroup() {
                    Spacer()
                    Button(action: changeCollection) {
                        Images.changeCollection.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle()).hidden().keyboardShortcut(.return, modifiers: [])
                    Button(action: showInfo) {
                        Images.info.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle())
                    Button(action: viewOnWeb) {
                        Images.globe.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle())
                }
            }.toolbar(!isFullscreen ? .visible : .hidden)
            .alert(Strings.experimetalOfflineGeneration, isPresented: $showingInfoAlert) {
                Button(Strings.ok) { }
            } message: {
                if let instructions = currentToken.instructions {
                    Text(Strings.letUsKnowOfIssues + "\n\n" + instructions)
                } else {
                    Text(Strings.letUsKnowOfIssues)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)) { notification in
                if (notification.object as? NSWindow)?.windowNumber == windowNumber {
                    NSCursor.setHiddenUntilMouseMoves(true)
                    isFullscreen = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didExitFullScreenNotification)) { notification in
                if (notification.object as? NSWindow)?.windowNumber == windowNumber {
                    isFullscreen = false
                }
            }
    }
    
    private func updateFullscreenStatus() {
        if let window = NSApplication.shared.windows.first(where: { $0.windowNumber == windowNumber }) {
            isFullscreen = window.styleMask.contains(.fullScreen)
            if isFullscreen {
                NSCursor.setHiddenUntilMouseMoves(true)
            }
        }
    }
    
    private func showInfo() {
        showingInfoAlert = true
    }
    
    private func viewOnWeb() {
        if let url = currentToken.url {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func changeCollection() {
        guard let last = history.last else { return }
        let newToken = TokenGenerator.generateRandomToken(specificCollectionId: nil, notCollectionId: last.fullCollectionId, notTokenId: nil) ?? currentToken
        history.append(newToken)
        currentIndex = history.count - 1
        currentToken = newToken
    }
    
    private func goBack() {
        if currentIndex > 0 {
            currentIndex -= 1
            currentToken = history[currentIndex]
        }
    }
    
    private func goForward() {
        if currentIndex < history.count - 1 {
            currentIndex += 1
            currentToken = history[currentIndex]
        } else {
            let newToken = TokenGenerator.generateRandomToken(specificCollectionId: currentToken.fullCollectionId, notCollectionId: nil, notTokenId: currentToken.id) ?? currentToken
            history.append(newToken)
            currentIndex += 1
            currentToken = newToken
        }
    }
    
}
