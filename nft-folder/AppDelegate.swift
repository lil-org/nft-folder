// nft-folder-macos 2023 ethistanbul

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let walletsService = WalletsService.shared
    
    private enum Request {
        case showWallets, addWallet
        
        var isNotShowWallets: Bool {
            switch self {
            case .showWallets, .addWallet:
                return false
            }
        }
        
    }
    
    private var window: NSWindow?
    private var timer: Timer?
    private let fileManager = FileManager.default
    private var didFinishLaunching = false
    private var initialRequest: Request?
    
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
        
        if let initialRequest = initialRequest, initialRequest.isNotShowWallets {
            processRequest(initialRequest)
        } else {
            processRequest(.showWallets)
        }
        
        initialRequest = nil
    }
    
    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        processInput(urlString: userActivity.webpageURL?.absoluteString)
        return true
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
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
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
        default:
            break
        }
        
        let viewPrefix = "view="
        if q.hasPrefix(viewPrefix), let encodedPath = q.dropFirst(viewPrefix.count).removingPercentEncoding {
            // TODO: show nft metadata
            print(encodedPath)
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
        var knownWallets = Set(walletsService.wallets.map { $0.displayName })
        for name in files {
            if knownWallets.contains(name) {
                knownWallets.remove(name)
            }
            if walletsService.isEthAddress(name) && !walletsService.hasWallet(name: name) {
                walletsService.resolveENS(name) { [weak self] result in
                    switch result {
                    case .success(let response):
                        let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar)
                        self?.walletsService.addWallet(wallet)
                        FolderIcon.set(for: wallet)
                        let old = path + "/" + name
                        let new = path + "/" + wallet.displayName
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
            walletsService.removeWallet(displayName: remaining)
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

