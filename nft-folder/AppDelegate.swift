// nft-folder-macos 2023 ethistanbul

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

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
        default:
            processRequest(.showWallets)
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

