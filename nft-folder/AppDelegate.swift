// ∅ nft-folder-macos 2024

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var didFinishLaunching = false
    private var window: NSWindow?
    private let currentInstanceId = UUID().uuidString
    
    private let allDownloadsManager = AllDownloadsManager.shared
    private let walletsService = WalletsService.shared
    private let fileManager = FileManager.default
    
    private var initialMessage: ExtensionMessage?
    
    override init() {
        super.init()
        let manager = NSAppleEventManager.shared()
        manager.setEventHandler(self, andSelector: #selector(self.getUrl(_:withReplyEvent:)),
                                forEventClass: AEEventClass(kInternetEventClass),
                                andEventID: AEEventID(kAEGetURL))
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createDirectoryIfNeeded()
        didFinishLaunching = true
        
        NSApplication.shared.servicesProvider = RightClickServiceProvider()
        NSUpdateDynamicServices()
        
        if let initialMessage = initialMessage {
            processMessage(initialMessage)
            self.initialMessage = nil
        } else {
            showPopup(addWallet: false)
        }
        
        let notificationCenter = DistributedNotificationCenter.default()
        notificationCenter.post(name: .mustTerminate, object: currentInstanceId)
        notificationCenter.addObserver(self, selector: #selector(terminateInstance(_:)), name: .mustTerminate, object: nil, suspensionBehavior: .deliverImmediately)
        notificationCenter.addObserver(self, selector: #selector(processFinderMessage(_:)), name: .fromFinder, object: nil, suspensionBehavior: .deliverImmediately)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    @objc private func processFinderMessage(_ notification: Notification) {
        guard let messageString = notification.object as? String,
              let message = ExtensionMessage.decodedFrom(string: messageString) else { return }
        processMessage(message)
    }
    
    private func processMessage(_ message: ExtensionMessage) {
        guard didFinishLaunching else {
            initialMessage = message
            return
        }
        
        switch message {
        case .didSelectSyncMenuItem:
            syncIfNeeded()
        case .didSelectControlCenterMenuItem:
            showPopup(addWallet: false)
        case .didSelectViewOnMenuItem(let path, let gallery):
            if let filePath = path.removingPercentEncoding {
                FileDownloader.shared.showNFT(filePath: filePath, gallery: gallery)
            }
        case .didBeginObservingDirectory(let mbAddressName):
            allDownloadsManager.prioritizeDownloads(mbAddressFolderName: mbAddressName)
        case .didEndObservingDirectory:
            break
        case .somethingChangedInHomeDirectory:
            checkFolders()
        }
    }
    
    @objc private func terminateInstance(_ notification: Notification) {
        guard let senderId = notification.object as? String else { return }
        if senderId != currentInstanceId {
            NSApplication.shared.terminate(nil)
        }
    }
    
    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        processInput(urlString: userActivity.webpageURL?.absoluteString)
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    private func createDirectoryIfNeeded() {
        _ = URL.nftDirectory
    }
    
    // TODO: move it from here
    private func showPopup(addWallet: Bool) {
        checkFolders()
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
    
    @objc private func getUrl(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        processInput(urlString: event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue)
    }
    
    private func processInput(urlString: String?) {
        if let urlString = urlString, urlString.hasPrefix(URL.deeplinkScheme),
           let message = ExtensionMessage.decodedFrom(string: String(urlString.dropFirst(URL.deeplinkScheme.count))) {
            processMessage(message)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApplication.shared.windows.forEach { $0.close() }
        showPopup(addWallet: false)
        return true
    }
    
    // TODO: move it from here. always check for running syncs before starting new ones
    private func syncIfNeeded() {
        for wallet in walletsService.wallets {
            WalletDownloader.shared.study(wallet: wallet)
        }
    }
    
    // TODO: move it from here
    @objc private func checkFolders() {
        guard let path = URL.nftDirectory?.path, let files = try? fileManager.contentsOfDirectory(atPath: path) else { return }
        var knownWallets = Set(walletsService.wallets)
        for name in files {
            if let known = knownWallets.first(where: { $0.folderDisplayName == name }) {
                knownWallets.remove(known)
            }
            if walletsService.isEthAddress(name) && !walletsService.hasWallet(folderName: name) {
                walletsService.resolveENS(name) { [weak self] result in
                    switch result {
                    case .success(let response):
                        let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar)
                        self?.walletsService.addWallet(wallet)
                        FolderIcon.set(for: wallet)
                        let old = path + "/" + name
                        let new = path + "/" + wallet.folderDisplayName
                        do {
                            try self?.fileManager.moveItem(atPath: old, toPath: new)
                        } catch {
                            if self?.fileManager.fileExists(atPath: new) == true {
                                try? self?.fileManager.removeItem(atPath: old)
                            }
                        }
                        WalletDownloader.shared.study(wallet: wallet)
                    case .failure:
                        return
                    }
                }
            }
        }
        
        for remaining in knownWallets {
            // TODO: stop downloads for that wallet as well
            walletsService.removeWallet(address: remaining.address)
        }
    }
    
}
