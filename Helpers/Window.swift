// ∅ nft-folder-macos 2024

import Cocoa

struct Window {
    
    static func closeAll() {
        NSApplication.shared.windows.forEach {
            if !($0.className == "NSStatusBarWindow") {
                $0.close()
            }
        }
    }
    
}
