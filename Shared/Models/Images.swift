// ∅ nft-folder 2024

import Cocoa

struct Images {
    
    static var icon: NSImage { named("icon") }
    static var folder: NSImage { named("folder") }
    static var zora: NSImage { named("zora") }
    static var mintfun: NSImage { named("mintfun") }
    static var opensea: NSImage { named("opensea") }
    static var infoTitleBar: NSImage { systemName("info.circle") }
    static var backTitleBar: NSImage { systemName("chevron.backward") }
    static var forwardTitleBar: NSImage { systemName("chevron.forward") }
    static var nextCollectionTitleBar: NSImage { systemName("goforward") }
    
    private static func named(_ name: String) -> NSImage {
        return NSImage(named: name)!
    }
    
    private static func systemName(_ systemName: String) -> NSImage {
        return NSImage(systemSymbolName: systemName, accessibilityDescription: nil)!
    }
    
}

