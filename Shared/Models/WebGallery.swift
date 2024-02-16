// ∅ nft-folder-macos 2024

import Cocoa

enum WebGallery: Int, CaseIterable, Codable {
    
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
    
    func url(walletAddress: String) -> URL? {
        switch self {
        case .zora:
            return URL(string: "https://zora.co/\(walletAddress)")
        case .mintfun:
            return URL(string: "https://mint.fun/profile/\(walletAddress)")
        case .opensea:
            return URL(string: "https://opensea.io/\(walletAddress)")
        }
    }
    
}
