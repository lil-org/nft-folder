// ∅ nft-folder-macos 2024

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var didFinishLaunching = false
    private var initialMessage: ExtensionMessage?
    
    private let currentInstanceId = UUID().uuidString
    
    private let allDownloadsManager = AllDownloadsManager.shared
    
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
            Navigator.showControlCenter(addWallet: false)
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
            allDownloadsManager.syncOnUserRequestIfNeeded()
        case .didSelectControlCenterMenuItem:
            Navigator.showControlCenter(addWallet: false)
        case .didSelectViewOnMenuItem(let path, let gallery):
            if let filePath = path.removingPercentEncoding {
                Navigator.show(filePath: filePath, on: gallery)
            }
        case .didBeginObservingDirectory(let mbAddressName):
            allDownloadsManager.prioritizeDownloads(mbAddressFolderName: mbAddressName)
        case .didEndObservingDirectory:
            break
        case .somethingChangedInHomeDirectory:
            allDownloadsManager.checkFolders()
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
        Navigator.showControlCenter(addWallet: false)
        return true
    }
    
}
