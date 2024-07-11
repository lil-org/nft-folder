// ∅ nft-folder 2024

import Cocoa

struct HostAppMessenger {
    
    private static var hostIsRunning: Bool {
        return !NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.hostBundleId).isEmpty
    }
    
    static func send(_ message: ExtensionMessage) {
        if case .didEndObservingDirectory = message { return }
        guard let messageString = message.encodedString else { return }
        if hostIsRunning {
            DistributedNotificationCenter.default().post(name: .fromFinder, object: messageString)
        } else if let url = URL(string: URL.deeplinkScheme + messageString) {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
}
