// ∅ nft-folder 2024

import Cocoa
import SwiftUI

class Navigator: NSObject {
    
    private override init() { super.init() }
    static let shared = Navigator()
    
    func showNewFolderInput() {
        showControlCenter(addWallet: true)
    }
    
    func showControlCenter(addWallet: Bool) {
        AllDownloadsManager.shared.checkFolders()
        Window.closeAll()
        let contentView = WalletsListView(showAddWalletPopup: addWallet)
        let window = RightClickActivatingWindow(
            contentRect: CGRect(origin: .zero, size: CGSize(width: 300, height: 420)),
            styleMask: [.closable, .fullSizeContentView, .titled, .resizable],
            backing: .buffered, defer: false)
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = false
        window.isMovableByWindowBackground = false
        window.backgroundColor = NSColor.windowBackgroundColor
        window.isOpaque = false
        window.hasShadow = true
        window.isRestorable = true
        window.setFrameAutosaveName(Consts.controlCenterFrameAutosaveName)
        
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 10
        window.contentView?.layer?.masksToBounds = true
        
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: contentView.frame(minWidth: 300, minHeight: 300))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        
        if window.frame.origin == .zero || !window.isOnActiveSpace || !window.isVisible {
            window.center()
        }
    }
    
    func showNftMetadata(filePath: String) {
        guard let metadata = MetadataStorage.detailedMetadata(nftFilePath: filePath) else {
            let alert = NSAlert()
            alert.messageText = Strings.somethingWentWrong
            alert.alertStyle = .informational
            alert.addButton(withTitle: Strings.ok)
            _ = alert.runModal()
            return
        }
        
        let contentView = MetadataView(metadata: metadata)
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
            } else if let wallet = WalletsService.shared.wallet(folderName: name), let galleryURL = gallery.url(wallet: wallet) {
                DispatchQueue.main.async { NSWorkspace.shared.open(galleryURL) }
            }
        } else if case gallery = .local {
            showNftMetadata(filePath: filePath)
        } else if let nftURL = MetadataStorage.nftURL(filePath: filePath, gallery: gallery) {
            DispatchQueue.main.async { NSWorkspace.shared.open(nftURL) }
        }
    }
    
}
