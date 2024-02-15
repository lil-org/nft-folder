// ∅ nft-folder-macos 2024

import Cocoa

// TODO: refactor
struct HostAppMessenger {
    
    static func didSelectSyncMenuItem() {
        if let url = URL(string: URL.deeplinkScheme + "?sync") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    static func didSelectViewOnMenuItem(path: String, gallery: WebGallery) {
        if let url = URL(string: URL.deeplinkScheme + "?view=\(path)\(gallery.rawValue)") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    static func didSelectControlCenterMenuItem() {
        if let url = URL(string: URL.deeplinkScheme + "?show") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    static func didBeginObservingDirectory() {
        if let deeplink = URL(string: URL.deeplinkScheme + "?monitor") {
            DispatchQueue.main.async { NSWorkspace.shared.open(deeplink) }
        }
    }
    
    static func didEndObservingDirectory() {
        if let deeplink = URL(string: URL.deeplinkScheme + "?stop-monitoring") {
            DispatchQueue.main.async { NSWorkspace.shared.open(deeplink) }
        }
    }
    
    static func didNoticeNewAddressFolder() { // TODO: not sure about this one. maybe checking from host is enough
        if let url = URL(string: URL.deeplinkScheme + "?check") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    static func didFireDirectoryMonitorEvent() { // TODO: clarify. do not ask for a check directly, notify of event instead
        if let url = URL(string: URL.deeplinkScheme + "?check") {
            DispatchQueue.main.async { NSWorkspace.shared.open(url) }
        }
    }
    
    private static func send(_ message: ExtensionMessage) {
        // TODO: implement
    }
    
}
