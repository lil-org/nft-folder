// ∅ nft-folder-macos 2024

import Cocoa

enum Badge: String, CaseIterable {
    case base, ok
    
    var image: NSImage {
        return NSImage(named: NSImage.statusAvailableName)!
    }
}
