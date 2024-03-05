// ∅ nft-folder-macos 2024

import Cocoa

class RightClickActivatingWindow: NSWindow {
    
    override func sendEvent(_ event: NSEvent) {
        if event.type == .rightMouseDown, !isKeyWindow || !isMainWindow {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        super.sendEvent(event)
    }

}
