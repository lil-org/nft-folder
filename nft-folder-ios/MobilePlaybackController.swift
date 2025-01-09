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
    
    func getCurrentToken(displayId: UUID) -> GeneratedToken {
        guard let display = displays[displayId] else { return GeneratedToken.empty }
        let (x, y) = display.getCurrentCoordinate()
        let token = getToken(uuid: displayId, x: x, y: y)
        return token
    }
    
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
    }
    
    private var collectionIds = [Int: String]() // TODO: different for different displays
    
    func getToken(uuid: UUID, x: Int, y: Int) -> GeneratedToken {
        // TODO: implement with history
        guard let initialConfig = initialConfigs[uuid] else { return GeneratedToken.empty }
        
        let token: GeneratedToken?
        
        if let collectionId = collectionIds[y] {
            token = TokenGenerator.generateRandomToken(specificCollectionId: collectionId, notTokenId: nil)
        } else {
            token = TokenGenerator.generateRandomToken(specificCollectionId: y == 0 ? initialConfig.initialItemId : nil, notTokenId: nil)
            collectionIds[y] = token?.fullCollectionId
        }
        
        return token ?? .empty
    }
    
}
