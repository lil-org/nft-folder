// ∅ nft-folder-macos 2024

import Cocoa

enum NftGallery: Int, CaseIterable, Codable {
    
    static let referrer = "0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE"
    
    case zora, mintfun, opensea, local
    
    var image: NSImage {
        switch self {
        case .local:
            return Images.folder
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
        case .local:
            Strings.nftInfo
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
        case .local:
            return nil
        case .zora:
            return URL(string: "https://zora.co/\(walletAddress)?referrer=\(NftGallery.referrer)")
        case .mintfun:
            return URL(string: "https://mint.fun/profile/\(walletAddress)?ref=\(NftGallery.referrer)")
        case .opensea:
            return URL(string: "https://opensea.io/\(walletAddress)")
        }
    }
    
}
