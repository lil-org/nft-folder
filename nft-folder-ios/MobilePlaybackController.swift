// ∅ 2025 lil org

import UIKit

protocol MobilePlaybackControllerDisplay: AnyObject {
    
    func navigate(_ direction: PlaybackNavigationDirection)
    
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
        // TODO: implement
        return GeneratedToken.empty
    }
    
    func showNewToken(displayId: UUID, token: GeneratedToken) {
        guard let display = displays[displayId] else { return }
        // TODO: implement
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
    
    func getToken(uuid: UUID, x: Int, y: Int) -> GeneratedToken {
        let randomColor = String(format: "#%06X", Int.random(in: 0x000000...0xFFFFFF))
        let html = """
        <html>
        <body style="margin:0; display:flex; justify-content:center; align-items:center; background-color:\(randomColor);">
            <div style="font-size:48px; font-weight:bold; color:#FFFFFF;">
                (\(x), \(y))
            </div>
        </body>
        </html>
        """
        
        let token = GeneratedToken(fullCollectionId: "", address: "", id: "", html: html, displayName: "", url: nil, instructions: nil, screensaver: nil)
        return token
    }
    
}
