// ∅ nft-folder 2024

import Cocoa

struct Images {
    
    static var icon: NSImage { named("icon") }
    static var folder: NSImage { named("folder") }
    static var zora: NSImage { named("zora") }
    static var mintfun: NSImage { named("mintfun") }
    static var opensea: NSImage { named("opensea") }
    
    private static func named(_ name: String) -> NSImage {
        return NSImage(named: name)!
    }
    
    private static func systemName(_ systemName: String) -> NSImage {
        return NSImage(systemSymbolName: systemName, accessibilityDescription: nil)!
    }
    
}

