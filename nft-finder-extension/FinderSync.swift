// ∅ nft-folder-macos 2024

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    private let home = URL.nftDirectory!
    private let monitor: DirectoryMonitor
    
    override init() {
        self.monitor = DirectoryMonitor(directoryURL: home)
        super.init()
        FIFinderSyncController.default().directoryURLs = [home]
        setupBadgeImages()
        monitor.startMonitoring()
    }
    
    private func setupBadgeImages() {
        for badge in [Badge.ok, Badge.base] {
            FIFinderSyncController.default().setBadgeImage(badge.image, label: "", forBadgeIdentifier: badge.rawValue)
        }
    }
    
    private func setBadgeFor(url: URL) {
        let badge: Badge?
        var components = url.pathComponents
        guard components.count > 2 else { return } // TODO: straightforward folder matching
        
        // TODO: return quickly when asking for a badge deep inside
        
        let folder = components.removeLast()
        let base = components.removeLast()
        
        if folder == "nft" { // TODO: exact full path folder matching
            badge = .base
        } else if base == "nft" {
            if WalletsService.shared.hasWallet(folderName: folder) {
                badge = .ok
            } else if WalletsService.shared.isEthAddress(folder) {
                if let url = URL(string: URL.deeplinkScheme + "?check") { // TODO: do not perform checks on badge request
                    DispatchQueue.main.async { NSWorkspace.shared.open(url) }
                }
                badge = nil
            } else {
                badge = nil
            }
        } else {
            badge = nil
        }
        
        if let id = badge?.rawValue {
            FIFinderSyncController.default().setBadgeIdentifier(id, for: url)
        }
    }
    
    // MARK: - directory observing
    
    override func beginObservingDirectory(at url: URL) {
        if url.path == URL.nftDirectory?.path, let deeplink = URL(string: URL.deeplinkScheme + "?monitor") {
            DispatchQueue.main.async { NSWorkspace.shared.open(deeplink) }
        }
    }
    
    override func endObservingDirectory(at url: URL) {
        if url.path == URL.nftDirectory?.path, let deeplink = URL(string: URL.deeplinkScheme + "?stop-monitoring") {
            DispatchQueue.main.async { NSWorkspace.shared.open(deeplink) }
        }
    }
    
    override func requestBadgeIdentifier(for url: URL) {
        setBadgeFor(url: url)
    }
    
    // MARK: - menu items
    
    override var toolbarItemName: String {
        return Strings.toolbarItemName
    }
    
    override var toolbarItemToolTip: String {
        return Strings.toolbarItemToolTip
    }
    
    override var toolbarItemImage: NSImage {
        return Images.icon
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        switch menuKind {
        case .contextualMenuForItems:
            for gallery in WebGallery.allCases {
                let item = NSMenuItem(title: gallery.title, action: #selector(viewOnWeb(_:)), keyEquivalent: "")
                item.tag = gallery.rawValue
                item.image = gallery.image
                menu.addItem(item)
            }
            
        case .toolbarItemMenu:
            menu.addItem(withTitle: Strings.openFolderMenuItem, action: #selector(openNFTDirectory(_:)), keyEquivalent: "")
            menu.addItem(withTitle: Strings.syncMenuItem, action: #selector(syncNFTs(_:)), keyEquivalent: "")
            menu.addItem(withTitle: Strings.controlCenterMenuItem, action: #selector(didSelectSettings(_:)), keyEquivalent: "")
        case .contextualMenuForContainer, .contextualMenuForSidebar:
            break
        @unknown default:
            break
        }
        return menu
    }
    
    @IBAction private func syncNFTs(_ sender: AnyObject?) {
        if let url = URL(string: URL.deeplinkScheme + "?sync") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    @IBAction private func didSelectSettings(_ sender: AnyObject?) {
        if let url = URL(string: URL.deeplinkScheme + "?show") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    @IBAction private func openNFTDirectory(_ sender: AnyObject?) {
        if let url = URL.nftDirectory {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    @objc private func viewOnWeb(_ sender: NSMenuItem) {
        guard let gallery = WebGallery(rawValue: sender.tag),
              let selectedItems = FIFinderSyncController.default().selectedItemURLs(), selectedItems.count == 1,
              let selectedPath = selectedItems.first?.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        if let url = URL(string: URL.deeplinkScheme + "?view=\(selectedPath)\(gallery.rawValue)") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }

}
