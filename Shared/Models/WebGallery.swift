// ∅ nft-folder-macos 2024

import Cocoa

enum WebGallery: Int, CaseIterable {
    
    case zora, mintfun, opensea
    
    var image: NSImage {
        switch self {
        case .zora:
            return Images.zora
        case .mintfun:
            return Images.mintfun
        case .opensea:
            return Images.opensea
        }
    }
    
    var title: String {
        switch self {
        case .zora:
            Strings.zora
        case .mintfun:
            Strings.mintfun
        case .opensea:
            Strings.opensea
        }
    }
    
}
