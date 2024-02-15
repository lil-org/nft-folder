// ∅ nft-folder-macos 2024

import Cocoa

enum Badge: String, CaseIterable {
    
    case nftFolder
    
    var image: NSImage {
        return NSImage(named: NSImage.statusAvailableName)!
    }
    
    var label: String {
        return Strings.nftFolder
    }
    
}
