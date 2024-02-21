// ∅ nft-folder-macos 2024

import Cocoa
import SwiftUI

class Navigator: NSObject {
    
    private var window: NSWindow?
    
    private override init() { super.init() }
    static let shared = Navigator()
    
    func showControlCenter(addWallet: Bool) {
        NSApplication.shared.windows.forEach { $0.close() }
        window?.close()
        let contentView = WalletsListView(showAddWalletPopup: addWallet)
        window = NSWindow(
            contentRect: NSRect(origin: .zero, size: Defaults.controlCenterWindowSize),
            styleMask: [.closable, .fullSizeContentView, .titled, .resizable],
            backing: .buffered, defer: false)
        window?.center()
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = false
        window?.delegate = self
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
    
    // TODO: refactor, clean up
    func showNftMetadata(filePath: String) {
        let contentView = MetadataView(metadata: MetadataStorage.detailedMetadata(nftFilePath: filePath))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.closable, .fullSizeContentView, .titled, .resizable],
            backing: .buffered, defer: false)
        window.center()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = true
        window.backgroundColor = NSColor.windowBackgroundColor
        window.isOpaque = false
        window.hasShadow = true
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 10
        window.contentView?.layer?.masksToBounds = true
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: contentView.frame(minWidth: 300, minHeight: 300))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
    
    func show(filePath: String, on gallery: NftGallery) {
        let fileUrl = URL(filePath: filePath)
        if fileUrl.pathComponents.count == URL.nftDirectoryPathComponentsCount {
            DispatchQueue.main.async { self.showControlCenter(addWallet: false) }
        } else if fileUrl.pathComponents.count == URL.nftDirectoryPathComponentsCount + 1 {
            let name = fileUrl.lastPathComponent
            if case gallery = .local {
                DispatchQueue.main.async { self.showControlCenter(addWallet: false) }
            } else if let wallet = WalletsService.shared.wallet(folderName: name), let galleryURL = gallery.url(walletAddress: wallet.address) {
                DispatchQueue.main.async { NSWorkspace.shared.open(galleryURL) }
            }
        } else if case gallery = .local {
            showNftMetadata(filePath: filePath)
        } else if let nftURL = MetadataStorage.nftURL(filePath: filePath, gallery: gallery) {
            DispatchQueue.main.async { NSWorkspace.shared.open(nftURL) }
        }
    }
    
}

extension Navigator: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            Defaults.controlCenterWindowSize = window.frame.size
        }
    }
    
}
