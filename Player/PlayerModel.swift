// ∅ nft-folder 2024

import SwiftUI

class PlayerModel: ObservableObject {
    
    @Published var currentToken: GeneratedToken
    @Published var history: [GeneratedToken]
    @Published var currentIndex: Int = 0

    init() {
        let token = TokenGenerator.generateRandomToken(specificCollectionId: nil, notTokenId: nil) ?? GeneratedToken.empty
        self.currentToken = token
        self.history = [token]
    }
    
    func goBack() {
        if currentIndex > 0 {
            currentIndex -= 1
            currentToken = history[currentIndex]
        }
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
    }

    func changeCollection() {
        let newToken = TokenGenerator.generateRandomToken(specificCollectionId: nil, notTokenId: nil) ?? currentToken
        history.append(newToken)
        currentIndex = history.count - 1
        currentToken = newToken
        freeUpHistoryIfNeeded()
    }
    
    private func freeUpHistoryIfNeeded() {
        if history.count > 23 {
            let cutTarget = 10
            history.removeFirst(history.count - cutTarget)
            currentIndex = cutTarget - 1
        }
    }
}