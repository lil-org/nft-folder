// ∅ nft-folder 2024

import Cocoa

class StatusBarItem: NSObject {
    
    static let shared = StatusBarItem()
    private override init() { super.init() }
    
    private var statusBarItem: NSStatusItem?
    
    func showIfNeeded() {
        guard !Defaults.hideFromMenuBar else { return }
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem?.button?.image = Images.icon
        statusBarItem?.button?.imagePosition = .imageOnly
        statusBarItem?.button?.imageScaling = .scaleProportionallyDown
        statusBarItem?.button?.target = self
        statusBarItem?.button?.action = #selector(statusBarButtonClicked(sender:))
    }
    
    private func createMenu() -> NSMenu {
        let menu = NSMenu(title: Strings.nftFolder)
        menu.delegate = self
        let openFolderItem = NSMenuItem(title: Strings.openFolderMenuItem, action: #selector(openNftFolder), keyEquivalent: "")
        let controlCenterItem = NSMenuItem(title: Strings.controlCenterMenuItem, action: #selector(showControlCenter), keyEquivalent: "")
        
        let syncItem = NSMenuItem(title: Strings.sync, action: #selector(didSelectSyncMenuItem(_:)), keyEquivalent: "")
        let newFolderItem = NSMenuItem(title: Strings.newFolderMenuItem, action: #selector(didSelectNewFolderMenuItem), keyEquivalent: "")
        let hideItem = NSMenuItem(title: Strings.hideFromHere, action: #selector(hideFromHere), keyEquivalent: "")
        let quitItem = NSMenuItem(title: Strings.quit, action: #selector(warnBeforeQuitting), keyEquivalent: "q")
        
        controlCenterItem.target = self
        openFolderItem.target = self
        syncItem.target = self
        newFolderItem.target = self
        hideItem.target = self
        quitItem.target = self
        
        menu.addItem(newFolderItem)
        menu.addItem(controlCenterItem)
        menu.addItem(openFolderItem)
        menu.addItem(syncItem)
        
        if SharedDefaults.downloadsInProgress {
            let stopDownloadsItem = NSMenuItem(title: Strings.stopAllDownloads, action: #selector(stopAllDownloads(_:)), keyEquivalent: "")
            stopDownloadsItem.target = self
            menu.addItem(stopDownloadsItem)
        }
        
        menu.addItem(.separator())
        menu.addItem(hideItem)
        menu.addItem(quitItem)
        return menu
    }
    
    @objc private func stopAllDownloads(_ sender: AnyObject?) {
        AllDownloadsManager.shared.stopAllDownloads()
    }
    
    @objc private func didSelectNewFolderMenuItem(_ sender: AnyObject?) {
        Navigator.shared.showNewFolderInput()
    }
    
    @objc private func didSelectSyncMenuItem(_ sender: AnyObject?) {
        AllDownloadsManager.shared.syncOnUserRequestIfNeeded(mbAddressFolderName: nil)
    }
    
    @objc private func statusBarButtonClicked(sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent, event.type == .rightMouseUp || event.type == .leftMouseUp else { return }
        statusBarItem?.menu = createMenu()
        statusBarItem?.button?.performClick(nil)
    }
    
    @objc private func openNftFolder() {
        if let url = URL.nftDirectory {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func hideFromHere() {
        Defaults.hideFromMenuBar = true
        hideFromMenuBar()
    }
    
    @objc func hideFromMenuBar() {
        if let item = statusBarItem {
            NSStatusBar.system.removeStatusItem(item)
        }
    }
    
    @objc private func showControlCenter() {
        Navigator.shared.showControlCenter(addWallet: false)
    }
    
    @objc private func warnBeforeQuitting() {
        let alert = NSAlert()
        alert.messageText = Strings.quit + "?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: Strings.ok)
        alert.addButton(withTitle: Strings.cancel)
        alert.buttons.last?.keyEquivalent = "\u{1b}"
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            NSApp.terminate(nil)
        default:
            break
        }
    }
    
}

extension StatusBarItem: NSMenuDelegate {
    
    func menuDidClose(_ menu: NSMenu) {
        statusBarItem?.menu = nil
    }
    
}
