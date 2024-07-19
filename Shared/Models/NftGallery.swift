// ∅ nft-folder 2024

import Cocoa

enum NftGallery: Int, CaseIterable, Codable {
    
    static let referrer = "0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE"
    
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
    
    func url(wallet: WatchOnlyWallet) -> URL? {
        if let collectionNetwork = wallet.collections?.first?.network {
            return url(network: collectionNetwork, chain: wallet.chain, collectionAddress: wallet.address, tokenId: nil)
        } else {
            return url(walletAddress: wallet.address, chain: wallet.chain)
        }
    }
    
    private func url(walletAddress: String, chain: Chain?) -> URL? {
        // TODO: use chain for non eth explorers
        // https://magiceden.io/marketplace/CjL5WpAmf4cMEEGwZGTfTDKWok9a92ykq9aLZrEK2D5H
        
        switch self {
        case .zora:
            return URL(string: "https://zora.co/\(walletAddress)?referrer=\(NftGallery.referrer)")
        case .mintfun:
            return URL(string: "https://mint.fun/profile/\(walletAddress)?ref=\(NftGallery.referrer)")
        case .opensea:
            return URL(string: "https://opensea.io/\(walletAddress)")
        }
    }
    
    func url(network: Network, chain: Chain?, collectionAddress: String, tokenId: String?) -> URL? {
        // TODO: use chain for non eth explorers
        switch self {
        case .zora:
            let prefix: String
            switch network {
            case .mainnet:
                prefix = "eth"
            case .optimism:
                prefix = "optimism"
            case .zora:
                prefix = "zora"
            case .base:
                prefix = "base"
            case .arbitrum:
                prefix = "arb"
            case .blast:
                prefix = "blast"
            }
            return URL(string: "https://zora.co/collect/\(prefix):\(collectionAddress)/\(tokenId ?? "")?referrer=\(NftGallery.referrer)")
        case .mintfun:
            let prefix: String
            switch network {
            case .mainnet:
                prefix = "ethereum"
            case .optimism:
                prefix = "op"
            case .zora:
                prefix = "zora"
            case .base:
                prefix = "base"
            case .arbitrum:
                prefix = "arbitrum"
            case .blast:
                prefix = "blast"
            }
            return URL(string: "https://mint.fun/\(prefix)/\(collectionAddress)?ref=\(NftGallery.referrer)")
        case .opensea:
            let prefix: String
            switch network {
            case .mainnet:
                prefix = "ethereum"
            case .optimism:
                prefix = "optimism"
            case .zora:
                prefix = "zora"
            case .base:
                prefix = "base"
            case .arbitrum:
                prefix = "arbitrum"
            case .blast:
                prefix = "blast"
            }
            return URL(string: "https://opensea.io/assets/\(prefix)/\(collectionAddress)/\(tokenId ?? "")")
        }
    }
    
}
