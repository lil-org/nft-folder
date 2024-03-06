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
        for badge in Badge.allCases {
            FIFinderSyncController.default().setBadgeImage(badge.image, label: badge.label, forBadgeIdentifier: badge.rawValue)
        }
    }
    
    private func setBadgeFor(url: URL) {
        let pathComponents = url.pathComponents
        if pathComponents.count == URL.nftDirectoryPathComponentsCount {
            FIFinderSyncController.default().setBadgeIdentifier(Badge.nftFolder.rawValue, for: url)
        } else if pathComponents.count - 1 == URL.nftDirectoryPathComponentsCount, let name = pathComponents.last {
            if SharedDefaults.hasWallet(folderName: name) {
                FIFinderSyncController.default().setBadgeIdentifier(Badge.nftFolder.rawValue, for: url)
            }
        }
    }
    
    // MARK: - directory observing
    
    override func beginObservingDirectory(at url: URL) {
        let pathComponents = url.pathComponents
        if pathComponents.count == URL.nftDirectoryPathComponentsCount {
            HostAppMessenger.send(.didBeginObservingDirectory(mbAddressName: nil))
        } else if pathComponents.count - 1 == URL.nftDirectoryPathComponentsCount, let last = pathComponents.last {
            HostAppMessenger.send(.didBeginObservingDirectory(mbAddressName: last))
        }
    }
    
    override func endObservingDirectory(at url: URL) {
        let pathComponents = url.pathComponents
        if pathComponents.count == URL.nftDirectoryPathComponentsCount {
            HostAppMessenger.send(.didEndObservingDirectory(mbAddressName: nil))
        } else if pathComponents.count - 1 == URL.nftDirectoryPathComponentsCount, let last = pathComponents.last {
            HostAppMessenger.send(.didEndObservingDirectory(mbAddressName: last))
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
            for gallery in [NftGallery.zora, NftGallery.mintfun, NftGallery.opensea] {
                let item = NSMenuItem(title: gallery.title, action: #selector(viewOn(_:)), keyEquivalent: "")
                item.tag = gallery.rawValue
                item.image = gallery.image
                menu.addItem(item)
            }
            
        case .toolbarItemMenu:
            menu.addItem(withTitle: Strings.newFolderMenuItem, action: #selector(didSelectNewFolderMenuItem(_:)), keyEquivalent: "")
            menu.addItem(withTitle: Strings.controlCenterMenuItem, action: #selector(didSelectControlCenterMenuItem(_:)), keyEquivalent: "")
            menu.addItem(withTitle: Strings.openFolderMenuItem, action: #selector(openNFTDirectory(_:)), keyEquivalent: "")
            menu.addItem(withTitle: Strings.sync, action: #selector(didSelectSyncMenuItem(_:)), keyEquivalent: "")
            if SharedDefaults.downloadsInProgress {
                menu.addItem(withTitle: Strings.stopAllDownloads, action: #selector(stopAllDownloads(_:)), keyEquivalent: "")
            }
        case .contextualMenuForContainer, .contextualMenuForSidebar:
            break
        @unknown default:
            break
        }
        return menu
    }
    
    @IBAction private func stopAllDownloads(_ sender: AnyObject?) {
        HostAppMessenger.send(.didSelectStopAllDownloadsMenuItem)
    }
    
    @IBAction private func didSelectNewFolderMenuItem(_ sender: AnyObject?) {
        HostAppMessenger.send(.didSelectNewFolderMenuItem)
    }
    
    @IBAction private func didSelectSyncMenuItem(_ sender: AnyObject?) {
        var mbAddressName: String?
        if let pathComponents = FIFinderSyncController.default().targetedURL()?.pathComponents,
           pathComponents.count - 1 == URL.nftDirectoryPathComponentsCount,
           let last = pathComponents.last {
            mbAddressName = last
        } else {
            mbAddressName = nil
        }
        HostAppMessenger.send(.didSelectSyncMenuItem(mbAddressName: mbAddressName))
    }
    
    @IBAction private func didSelectControlCenterMenuItem(_ sender: AnyObject?) {
        HostAppMessenger.send(.didSelectControlCenterMenuItem)
    }
    
    @IBAction private func openNFTDirectory(_ sender: AnyObject?) {
        if let url = URL.nftDirectory {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    @objc private func viewOn(_ sender: NSMenuItem) {
        guard let gallery = NftGallery(rawValue: sender.tag), let selectedItems = FIFinderSyncController.default().selectedItemURLs() else { return }
        let paths = selectedItems.compactMap({ $0.path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) })
        HostAppMessenger.send(.didSelectViewOnMenuItem(paths: paths, gallery: gallery))
    }

}
