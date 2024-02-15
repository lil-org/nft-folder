// ∅ nft-folder-macos 2024

import Cocoa

struct HostAppMessenger {
    
    private static var hostIsRunning: Bool {
        return !NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.hostBundleId).isEmpty
    }
    
    static func send(_ message: ExtensionMessage) {
        // TODO: refactor
        // TODO: different send methods depending on hostIsRunning
        
        switch message {
        case .didSelectSyncMenuItem:
            if let url = URL(string: URL.deeplinkScheme + "?sync") {
                DispatchQueue.main.async { NSWorkspace.shared.open(url) }
            }
        case .didSelectControlCenterMenuItem:
            if let url = URL(string: URL.deeplinkScheme + "?show") {
                DispatchQueue.main.async { NSWorkspace.shared.open(url) }
            }
        case .didSelectViewOnMenuItem(let path, let gallery):
            if let url = URL(string: URL.deeplinkScheme + "?view=\(path)\(gallery.rawValue)") {
                DispatchQueue.main.async { NSWorkspace.shared.open(url) }
            }
        case .didBeginObservingDirectory(let mbAddressName):
            // TODO: pass address folder name
            if let deeplink = URL(string: URL.deeplinkScheme + "?monitor") {
                DispatchQueue.main.async { NSWorkspace.shared.open(deeplink) }
            }
        case .didEndObservingDirectory(let mbAddressName):
            // TODO: pass address folder name
            if let deeplink = URL(string: URL.deeplinkScheme + "?stop-monitoring") {
                DispatchQueue.main.async { NSWorkspace.shared.open(deeplink) }
            }
        case .somethingChangedInHomeDirectory:
            if let url = URL(string: URL.deeplinkScheme + "?check") { // TODO: do not ask for a check directly, notify of event instead
                DispatchQueue.main.async { NSWorkspace.shared.open(url) }
            }
        }
    }
    
}
