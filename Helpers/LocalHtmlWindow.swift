// ∅ nft-folder 2024

import Cocoa

class LocalHtmlWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        let titleBarView = standardWindowButton(.closeButton)?.superview
        titleBarView?.wantsLayer = true
        titleBarView?.layer?.backgroundColor = .black
    }
    
}
