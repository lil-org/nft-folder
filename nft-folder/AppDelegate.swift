// ∅ 2025 lil org

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var didFinishLaunching = false
    private let currentInstanceId = UUID().uuidString
    
    private let allDownloadsManager = AllDownloadsManager.shared
    
    override init() {
        super.init()
        alternativeResourcesPath = AmbientAgent.helperAppPath
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        cleanupDefaultsIfNeeded()
        createDirectoryIfNeeded()
        didFinishLaunching = true
        
        NSApplication.shared.servicesProvider = RightClickServiceProvider()
        NSUpdateDynamicServices()
        
        Navigator.shared.showControlCenter(addWallet: false)
        
        let notificationCenter = DistributedNotificationCenter.default()
        notificationCenter.post(name: .mustTerminate, object: currentInstanceId)
        notificationCenter.addObserver(self, selector: #selector(terminateInstance(_:)), name: .mustTerminate, object: nil, suspensionBehavior: .deliverImmediately)
        notificationCenter.addObserver(self, selector: #selector(restoreFromPip(_:)), name: .restoreFromPip, object: nil, suspensionBehavior: .deliverImmediately)
        allDownloadsManager.start()
        StatusBarItem.shared.showIfNeeded()
        AvatarService.setup()
    }
    
    private func cleanupDefaultsIfNeeded() {
        let currentVersion = Defaults.cleanupVersion
        if currentVersion == 0 {
            Defaults.performCleanup(version: currentVersion)
            SharedDefaults.performCleanup(version: currentVersion)
            Defaults.cleanupVersion = 1
        }
    }
    
    @objc func restoreFromPip(_ notification: Notification) {
        guard let jsonString = notification.object as? String,
              let data = jsonString.data(using: .utf8),
              let token = try? JSONDecoder().decode(GeneratedToken.self, from: data) else { return }
        DispatchQueue.main.async {
            Navigator.shared.showPlayer(model: PlayerModel(token: token))
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    @objc private func terminateInstance(_ notification: Notification) {
        guard let senderId = notification.object as? String else { return }
        if senderId != currentInstanceId {
            NSApplication.shared.terminate(nil)
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    private func createDirectoryIfNeeded() {
        _ = URL.nftDirectory
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        Navigator.shared.showControlCenter(addWallet: false)
        return true
    }
    
    @IBAction func didClickNewWindowItem(_ sender: Any) {
        Navigator.shared.showControlCenter(addWallet: false)
    }
    
}
