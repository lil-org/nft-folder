// ∅ nft-folder-macos 2024

import Cocoa
import SwiftUI

struct Navigator {
    
    private static var window: NSWindow?
    
    static func showControlCenter(addWallet: Bool) {
        window?.close()
        let contentView = WalletsListView(showAddWalletPopup: addWallet)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.closable, .fullSizeContentView, .titled, .resizable],
            backing: .buffered, defer: false)
        window?.center()
        window?.titleVisibility = .visible
        window?.titlebarAppearsTransparent = false
        window?.isMovableByWindowBackground = true
        window?.backgroundColor = NSColor.windowBackgroundColor
        window?.isOpaque = false
        window?.hasShadow = true
        
        window?.contentView?.wantsLayer = true
        window?.contentView?.layer?.cornerRadius = 10
        window?.contentView?.layer?.masksToBounds = true
        
        window?.isReleasedWhenClosed = false
        window?.contentView = NSHostingView(rootView: contentView.frame(minWidth: 300, minHeight: 300))
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
    
    static func show(filePath: String, on gallery: WebGallery) {
        if let nftURL = MetadataStorage.nftURL(filePath: filePath, gallery: gallery) {
            DispatchQueue.main.async { NSWorkspace.shared.open(nftURL) }
        }
    }
    
}
