// ∅ nft-folder 2024

import Cocoa

class LocalHtmlWindow: NSWindow {
    
    private var cursorHideTimer: Timer?
    private var mouseMoveEventMonitor: Any?

    private var isFullScreenOnActiveSpace: Bool {
        return styleMask.contains(.fullScreen) && isOnActiveSpace
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        let titleBarView = standardWindowButton(.closeButton)?.superview
        titleBarView?.wantsLayer = true
        titleBarView?.layer?.backgroundColor = .black
        
        if NSScreen.screens.count <= 1 {
            mouseMoveEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseUp, .rightMouseUp, .mouseEntered]) { [weak self] event in
                self?.resetCursorHideTimer()
                return event
            }
        }
    }
    
    private func resetCursorHideTimer() {
        cursorHideTimer?.invalidate()
        if isFullScreenOnActiveSpace {
            cursorHideTimer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false) { [weak self] _ in
                if self?.isFullScreenOnActiveSpace == true {
                    NSCursor.setHiddenUntilMouseMoves(true)
                }
            }
        }
    }
    
    deinit {
        if let monitor = mouseMoveEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
}
