// ∅ nft-folder-macos 2024

import Cocoa

struct Window {
    
    static func closeAll() {
        // TODO: not status tho
        NSApplication.shared.windows.forEach { $0.close() }
    }
    
}
