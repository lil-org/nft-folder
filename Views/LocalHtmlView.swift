// ∅ nft-folder 2024

import SwiftUI

struct LocalHtmlView: View {
    
    @State private var currentToken = TokenGenerator.generateRandomToken(specificCollectionId: nil, notCollectionId: nil, notTokenId: nil) ?? GeneratedToken(fullCollectionId: "", id: "", html: "", displayName: "", url: nil, instructions: nil)
    @State private var history = [GeneratedToken]()
    @State private var currentIndex = 0
    @State private var showingInfoAlert = false
    
    var body: some View {
        let toolbarButtonsColor = Color.gray
        DesktopWebView(htmlContent: currentToken.html)
            .onAppear {
                history.append(currentToken)
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
                    Button(action: showInfo) {
                        Images.info.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle())
                    Button(action: viewOnWeb) {
                        Images.globe.foregroundStyle(toolbarButtonsColor)
                    }.buttonStyle(LinkButtonStyle())
                }
            }
            .alert(Strings.experimetalOfflineGeneration, isPresented: $showingInfoAlert) {
                Button(Strings.ok) { }
            } message: {
                if let instructions = currentToken.instructions {
                    Text(Strings.letUsKnowOfIssues + "\n\n" + instructions)
                } else {
                    Text(Strings.letUsKnowOfIssues)
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
