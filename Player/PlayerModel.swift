// ∅ 2025 lil org

import SwiftUI

class PlayerModel: ObservableObject {
    
    let specificCollectionId: String?
    
    @Published var currentToken: GeneratedToken
    @Published var history: [GeneratedToken]
    @Published var currentIndex: Int = 0
    @Published var showingInfoPopover = false
    @Published var showingListPopover = false

    init(specificCollectionId: String?, notTokenId: String?) {
        let token = TokenGenerator.generateRandomToken(specificCollectionId: specificCollectionId, notTokenId: notTokenId) ?? GeneratedToken.empty
        self.currentToken = token
        self.history = [token]
        self.specificCollectionId = specificCollectionId
    }
    
    func showInitialCollection() {
        let newToken = TokenGenerator.generateRandomToken(specificCollectionId: specificCollectionId, notTokenId: nil) ?? currentToken
        showNewToken(newToken)
    }
    
    func goBack() {
        if currentIndex > 0 {
            currentIndex -= 1
            currentToken = history[currentIndex]
        }
        showingInfoPopover = false
        showingListPopover = false
    }

    func goForward() {
        if currentIndex < history.count - 1 {
            currentIndex += 1
            currentToken = history[currentIndex]
        } else {
            let newToken = TokenGenerator.generateRandomToken(specificCollectionId: currentToken.fullCollectionId, notTokenId: currentToken.id) ?? currentToken
            history.append(newToken)
            currentIndex = history.count - 1
            currentToken = newToken
            freeUpHistoryIfNeeded()
        }
        showingInfoPopover = false
        showingListPopover = false
    }

    func tryNavigatingTo(inputTokenId: String) {
        if let newToken = TokenGenerator.generateRandomToken(specificCollectionId: currentToken.fullCollectionId, specificInputTokenId: inputTokenId) {
            showNewToken(newToken)
        }
    }
    
    func changeCollection() {
        let newToken = TokenGenerator.generateRandomToken(specificCollectionId: nil, notTokenId: nil) ?? currentToken
        showNewToken(newToken)
    }
    
    func showNewToken(_ newToken: GeneratedToken) {
        history.append(newToken)
        currentIndex = history.count - 1
        currentToken = newToken
        freeUpHistoryIfNeeded()
        showingInfoPopover = false
        showingListPopover = false
    }
    
    private func freeUpHistoryIfNeeded() {
        if history.count > 23 {
            let cutTarget = 10
            history.removeFirst(history.count - cutTarget)
            currentIndex = cutTarget - 1
        }
    }
}
