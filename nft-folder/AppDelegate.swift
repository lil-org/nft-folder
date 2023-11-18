// nft-folder-macos 2023 ethistanbul

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private enum Request {
        case showWallets
        
        var isNotShowWallets: Bool {
            switch self {
            case .showWallets:
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
        NFTService.shared.study(address: "0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE")
        
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
        processInput(url: userActivity.webpageURL?.absoluteString)
        return true
    }
    
    private func createDirectoryIfNeeded() {
        _ = URL.nftDirectory
    }
    
    private func showPopup() {
        let contentView = WalletsListView()
        
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
        processInput(url: event.paramDescriptor(forKeyword: keyDirectObject)?.stringValue)
    }
    
    private func processInput(url: String?) {
        guard let url = url else { return }
        if url.hasPrefix(URL.deeplinkScheme) {
            processRequest(.showWallets)
        }
    }
    
    private func processRequest(_ request: Request) {
        if didFinishLaunching {
            switch request {
            case .showWallets:
                showPopup()
            }
        } else {
            initialRequest = request
        }
    }
    
}

