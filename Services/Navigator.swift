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
        let contentView = WalletsListView(showAddWalletPopup: addWallet, inPopup: false)
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
        window.contentView = NSHostingView(rootView: contentView.frame(minWidth: 250, minHeight: 130))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
        
        if window.frame.origin == .zero || !window.isOnActiveSpace || !window.isVisible {
            window.center()
        }
    }
    
    func show(filePath: String, on gallery: NftGallery) {
        let fileUrl = URL(filePath: filePath)
        if fileUrl.pathComponents.count == URL.nftDirectoryPathComponentsCount { // nft folder root
            DispatchQueue.main.async { self.showControlCenter(addWallet: false) }
        } else if fileUrl.pathComponents.count == URL.nftDirectoryPathComponentsCount + 1 { // address root
            let name = fileUrl.lastPathComponent
            if let wallet = WalletsService.shared.wallet(folderName: name), let galleryURL = gallery.url(wallet: wallet) {
                DispatchQueue.main.async { NSWorkspace.shared.open(galleryURL) }
            }
        } else if let nftURL = MetadataStorage.nftURL(filePath: filePath, gallery: gallery) { // specific nft
            DispatchQueue.main.async { NSWorkspace.shared.open(nftURL) }
        } else { // custom nft folder within
            let fileManager = FileManager.default
            var didOpenSome = false
            if let children = try? fileManager.contentsOfDirectory(at: fileUrl, includingPropertiesForKeys: nil) {
                for child in children {
                    if let nftURL = MetadataStorage.nftURL(filePath: child.path, gallery: gallery) {
                        didOpenSome = true
                        DispatchQueue.main.async { NSWorkspace.shared.open(nftURL) }
                    }
                }
            }
            if !didOpenSome && fileUrl.pathComponents.count > URL.nftDirectoryPathComponentsCount {
                let rootFolderName = fileUrl.pathComponents[URL.nftDirectoryPathComponentsCount]
                if let wallet = WalletsService.shared.wallet(folderName: rootFolderName), let galleryURL = gallery.url(wallet: wallet) {
                    DispatchQueue.main.async { NSWorkspace.shared.open(galleryURL) }
                }
            }
        }
    }
    
}
