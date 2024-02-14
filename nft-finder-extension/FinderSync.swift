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
        
        let folder = components.removeLast()
        let base = components.removeLast()
        
        if folder == "nft" {
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
        return "nft"
    }
    
    override var toolbarItemToolTip: String {
        return "click for nft menu"
    }
    
    override var toolbarItemImage: NSImage {
        return NSImage(named: "icon")!
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        let menu = NSMenu(title: "")
        switch menuKind {
        case .contextualMenuForItems:
            let zoraItem = NSMenuItem(title: "zora", action: #selector(viewOnZora(_:)), keyEquivalent: "")
            zoraItem.image = NSImage(named: NSImage.Name(stringLiteral: "zora"))
            let funItem = NSMenuItem(title: "mint.fun", action: #selector(viewOnMintFun(_:)), keyEquivalent: "")
            funItem.image = NSImage(named: NSImage.Name(stringLiteral: "fun"))
            let seaItem = NSMenuItem(title: "opensea", action: #selector(viewOnOpenSea(_:)), keyEquivalent: "")
            seaItem.image = NSImage(named: NSImage.Name(stringLiteral: "sea"))
            menu.addItem(zoraItem)
            menu.addItem(funItem)
            menu.addItem(seaItem)
        case .toolbarItemMenu:
            menu.addItem(withTitle: "📂 open nft folder", action: #selector(openNFTDirectory(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "⬇️ sync nfts", action: #selector(syncNFTs(_:)), keyEquivalent: "")
            menu.addItem(withTitle: "🎛️ control center", action: #selector(didSelectSettings(_:)), keyEquivalent: "")
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
    
    @IBAction private func viewOnZora(_ sender: AnyObject?) {
        viewOn(letter: "z")
    }
    
    @IBAction private func viewOnMintFun(_ sender: AnyObject?) {
        viewOn(letter: "f")
    }
    
    @IBAction private func viewOnOpenSea(_ sender: AnyObject?) {
        viewOn(letter: "o")
    }
    
    private func viewOn(letter: String) {
        guard let selectedItems = FIFinderSyncController.default().selectedItemURLs(),
              selectedItems.count == 1,
              let selectedPath = selectedItems.first?.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        if let url = URL(string: URL.deeplinkScheme + "?view=\(selectedPath)\(letter)") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }

}
