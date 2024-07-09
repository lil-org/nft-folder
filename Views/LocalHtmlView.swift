// ∅ nft-folder 2024

import SwiftUI

struct LocalHtmlView: View {
    
    @State private var currentToken = TokenGenerator.generateRandomToken() ?? GeneratedToken(html: "", displayName: "")
    @State private var history = [GeneratedToken]()
    @State private var currentIndex = 0
    
    var body: some View {
        DesktopWebView(htmlContent: currentToken.html)
            .onAppear {
                history.append(currentToken)
            }
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity).background(.black)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: goBack) {
                        Images.back
                    }
                    .disabled(currentIndex <= 0)
                    .keyboardShortcut(.leftArrow, modifiers: [])
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: goForward) {
                        Images.forward
                    }
                    .keyboardShortcut(.rightArrow, modifiers: [])
                }
                ToolbarItem(placement: .principal) {
                    Text(currentToken.displayName).font(.headline)
                }
            }
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
            let newToken = TokenGenerator.generateRandomToken() ?? currentToken
            history.append(newToken)
            currentIndex += 1
            currentToken = newToken
        }
    }
    
}
