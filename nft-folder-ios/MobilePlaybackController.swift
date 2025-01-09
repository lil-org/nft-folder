// ∅ 2025 lil org

import UIKit

protocol MobilePlaybackControllerDisplay: AnyObject {
    
    func navigate(_ direction: PlaybackNavigationDirection)
    func getCurrentCoordinate() -> (Int, Int)
    
}

enum PlaybackNavigationDirection {
    case up, down, back, forward
}

class MobilePlaybackController {
    
    private init() {}
    
    static let shared = MobilePlaybackController()
    
    private var displays = [UUID: MobilePlaybackControllerDisplay]()
    private var initialConfigs = [UUID: MobilePlayerConfig]()
    private var tokensDataSources = [UUID: GeneratedTokensDataSource]()
    
    func showNewToken(displayId: UUID, token: GeneratedToken) {
        guard let display = displays[displayId] else { return }
        // TODO: implement
        // TODO: push the token into history and navigate player down or forward – depending if it is from the same or different collection
    }
    
    func goForward(uuid: UUID) {
        guard let display = displays[uuid] else { return }
        display.navigate(.forward)
    }
    
    func goBack(uuid: UUID) {
        guard let display = displays[uuid] else { return }
        display.navigate(.back)
    }
    
    func goUp(uuid: UUID) {
        guard let display = displays[uuid] else { return }
        display.navigate(.up)
    }
    
    func goDown(uuid: UUID) {
        guard let display = displays[uuid] else { return }
        display.navigate(.down)
    }
    
    func subscribe(config: MobilePlayerConfig, display: MobilePlaybackControllerDisplay) {
        displays[config.id] = display
        initialConfigs[config.id] = config
    }
    
    func stopAndDisconnect(uuid: UUID) {
        displays.removeValue(forKey: uuid)
        initialConfigs.removeValue(forKey: uuid)
        tokensDataSources.removeValue(forKey: uuid)
    }
    
    func getToken(uuid: UUID, coordinate: PlayerCoordinate) -> GeneratedToken {
        guard let initialConfig = initialConfigs[uuid] else { return GeneratedToken.empty }
        if let dataSource = tokensDataSources[uuid] {
            return dataSource.getToken(coordinate: coordinate)
        } else {
            let newDataSource = GeneratedTokensDataSource(initialCollectionId: initialConfig.initialItemId, specificInitialToken: initialConfig.specificToken)
            tokensDataSources[uuid] = newDataSource
            return newDataSource.getToken(coordinate: coordinate)
        }
    }
    
}

private class GeneratedTokensDataSource {
    
    private let initialCollectionId: String?
    private let specificInitialToken: GeneratedToken?
    
    init(initialCollectionId: String?, specificInitialToken: GeneratedToken?) {
        self.initialCollectionId = initialCollectionId
        self.specificInitialToken = specificInitialToken
    }
    
    private var collectionIds = [Int: String]()
    private var tokenIds = [String: [Int: String]]()
    
    func getToken(coordinate: PlayerCoordinate) -> GeneratedToken {
        // TODO: it gets called twice for each new token — optimize it
        // TODO: pass notTokenId when possible to avoid duplicates
        let token: GeneratedToken?
        if let collectionId = collectionIds[coordinate.y] {
            if let tokenId = tokenIds[collectionId]?[coordinate.x] {
                token = TokenGenerator.generateRandomToken(specificCollectionId: collectionId, specificInputTokenId: tokenId)
            } else {
                token = TokenGenerator.generateRandomToken(specificCollectionId: collectionId, notTokenId: nil)
                if let token = token {
                    tokenIds[token.fullCollectionId]?[coordinate.x] = token.id
                }
            }
        } else {
            token = TokenGenerator.generateRandomToken(specificCollectionId: coordinate.y == 0 ? initialCollectionId : nil, notTokenId: nil)
            if let token = token {
                collectionIds[coordinate.y] = token.fullCollectionId
                tokenIds[token.fullCollectionId] = [coordinate.x: token.id]
            }
        }
        return token ?? .empty
    }
    
}
