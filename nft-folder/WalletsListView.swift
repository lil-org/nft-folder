// nft-folder-macos 2023 ethistanbul

import Cocoa
import SwiftUI

struct WalletsListView: View {
    
    var body: some View {
        VStack {
            List {
                Text("123")
            }
        }
    }
    
}

var popupWindow: NSWindow? // keep a reference within a NSViewController

extension NSViewController {
    
    func showPopup() {
        let contentView = WalletsListView()
        
        popupWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.closable, .fullSizeContentView, .titled],
            backing: .buffered, defer: false)
        popupWindow?.center()
        popupWindow?.titleVisibility = .hidden
        popupWindow?.titlebarAppearsTransparent = true
        popupWindow?.isMovableByWindowBackground = true
        popupWindow?.backgroundColor = NSColor.windowBackgroundColor
        popupWindow?.isOpaque = false
        popupWindow?.hasShadow = true
        
        popupWindow?.contentView?.wantsLayer = true
        popupWindow?.contentView?.layer?.cornerRadius = 10
        popupWindow?.contentView?.layer?.masksToBounds = true
        
        popupWindow?.isReleasedWhenClosed = false
        popupWindow?.contentView = NSHostingView(rootView: contentView)
        popupWindow?.makeKeyAndOrderFront(nil)
    }
    
}
