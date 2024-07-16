// ∅ nft-folder 2024

import SwiftUI
import AppKit

struct LocalHtmlView: View {
    
    private var windowNumber = 0
    
    @State private var currentToken = TokenGenerator.generateRandomToken(specificCollectionId: nil, notTokenId: nil) ?? GeneratedToken.empty
    @State private var history = [GeneratedToken]()
    @State private var currentIndex = 0
    @State private var showingInfoPopover = false
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
                    Button(action: { showingInfoPopover.toggle() }) {
                        Images.info.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle()).popover(isPresented: $showingInfoPopover, arrowEdge: .bottom) {
                        infoPopoverView()
                    }
                }
            }.toolbar(!isFullscreen ? .visible : .hidden)
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
    
    private func viewOnWeb() {
        if let url = currentToken.url {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func changeCollection() {
        let newToken = TokenGenerator.generateRandomToken(specificCollectionId: nil, notTokenId: nil) ?? currentToken
        history.append(newToken)
        currentIndex = history.count - 1
        currentToken = newToken
        freeUpHistoryIfNeeded()
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
            let newToken = TokenGenerator.generateRandomToken(specificCollectionId: currentToken.fullCollectionId, notTokenId: currentToken.id) ?? currentToken
            history.append(newToken)
            currentIndex += 1
            currentToken = newToken
            freeUpHistoryIfNeeded()
        }
    }
    
    private func freeUpHistoryIfNeeded() {
        if history.count > 23 {
            let cutTarget = 10
            history.removeFirst(history.count - cutTarget)
            currentIndex = cutTarget - 1
        }
    }
    
    private func getScreensaver() {
        if let screensaver = currentToken.screensaver {
            NSWorkspace.shared.open(screensaver)
        }
    }
    
    private func infoPopoverView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if currentToken.screensaver != nil {
                Button(Strings.setScreenSaver, action: getScreensaver).buttonStyle(LinkButtonStyle()).fontWeight(Font.Weight.semibold)
                Divider()
            }
            
            Button(Strings.viewOnOpensea, action: viewOnWeb).buttonStyle(LinkButtonStyle()).fontWeight(Font.Weight.semibold)
            
            if let instructions = currentToken.instructions {
                Divider()
                Text(instructions).font(.body)
            }
            
            Divider()
            
            Text(Strings.experimetalOfflineGeneration).font(.headline)
            Text(Strings.letUsKnowOfIssues).font(.footnote)
        }
        .padding().frame(width: 230)
    }
}
