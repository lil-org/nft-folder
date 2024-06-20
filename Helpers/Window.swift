// ∅ nft-folder 2024

import Cocoa

struct Window {
    
    static func closeAll() {
        NSApplication.shared.windows.forEach {
            if !($0.className == "NSStatusBarWindow") {
                $0.close()
            }
        }
    }
    
    static var thereAreSome: Bool {
        return NSApplication.shared.windows.contains(where: { $0.className != "NSStatusBarWindow" })
    }
    
}
