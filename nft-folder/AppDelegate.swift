// ∅ nft-folder-macos 2024

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let walletsService = WalletsService.shared
    
    private enum Request {
        case showWallets, addWallet
    }
    
    private var didProcessInput = false
    private var window: NSWindow?
    private var timer: Timer?
    private let fileManager = FileManager.default
    private var didFinishLaunching = false
    private var initialRequest: Request?
    private let currentInstanceId = UUID().uuidString
    
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
        
        if let initialRequest = initialRequest {
            processRequest(initialRequest)
        } else if !didProcessInput {
            processRequest(.showWallets)
        }
        
        initialRequest = nil
        
        let dNotificationCenter = DistributedNotificationCenter.default()
        dNotificationCenter.post(name: .mustTerminate, object: currentInstanceId)
        dNotificationCenter.addObserver(self, selector: #selector(terminateInstance(_:)), name: .mustTerminate, object: nil, suspensionBehavior: .deliverImmediately)
        dNotificationCenter.addObserver(self, selector: #selector(processFinderMessage(_:)), name: .fromFinder, object: nil, suspensionBehavior: .deliverImmediately)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    @objc func processFinderMessage(_ notification: Notification) {
        // TODO: implement
    }
    
    @objc func terminateInstance(_ notification: Notification) {
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
    
    private func showPopup(addWallet: Bool) {
        checkFolders()
        window?.close()
        let contentView = WalletsListView(showAddWalletPopup: addWallet)
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 400),
            styleMask: [.closable, .fullSizeContentView, .titled],
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
        window?.contentView = NSHostingView(rootView: contentView)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
    
    @objc private func getUrl(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        processInput(urlString: event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue)
    }
    
    private func processInput(urlString: String?) {
        guard let urlString = urlString, urlString.hasPrefix(URL.deeplinkScheme), let url = URL(string: urlString), let q = url.query() else { return }
        didProcessInput = true
        // TODO: add model for a messaging
        switch q {
        case "add":
            processRequest(.addWallet)
        case "show":
            processRequest(.showWallets)
        case "monitor":
            startTimer()
        case "stop-monitoring":
            stopTimer()
        case "check":
            checkFolders()
        case "sync":
            syncIfNeeded()
        default:
            break
        }
        
        let viewPrefix = "view="
        if q.hasPrefix(viewPrefix),
           let rawGallery = q.last,
           let gallery = WebGallery(rawValue: String(rawGallery)),
           let encodedPath = q.dropFirst(viewPrefix.count).dropLast().removingPercentEncoding {
            DownloadsService.shared.showNFT(filePath: encodedPath, gallery: gallery)
            // TODO: different for wallet folders
            // TODO: open multiple files
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSApplication.shared.windows.forEach { $0.close() }
        showPopup(addWallet: false)
        return true
    }
    
    private func syncIfNeeded() {
        checkFolders()
        for wallet in walletsService.wallets {
            NFTService.shared.study(wallet: wallet)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkFolders), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        checkFolders()
    }
    
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
                        NFTService.shared.study(wallet: wallet)
                    case .failure:
                        return
                    }
                }
            }
        }
        
        for remaining in knownWallets {
            walletsService.removeWallet(address: remaining.address)
        }
    }
    
    private func processRequest(_ request: Request) {
        if didFinishLaunching {
            switch request {
            case .showWallets:
                showPopup(addWallet: false)
            case .addWallet:
                showPopup(addWallet: true)
            }
        } else {
            initialRequest = request
        }
    }
    
}

