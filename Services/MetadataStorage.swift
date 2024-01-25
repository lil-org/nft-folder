// ∅ nft-folder-macos 2024

import Foundation

struct MetadataStorage {
    
    // TODO: wipe defaults on a migration update
    private static let defaults = UserDefaults.standard
    
    static func store(fileId: String, metadata: MinimalTokenMetadata) {
        // TODO: store in a separate file
    }
    
    static func nftURL(fileId: String) -> URL? {
        // TODO: read from file
        return nil
    }
    
    // TODO: refactor
    private static func nftURL(metadata: MinimalTokenMetadata, network: Network) -> URL? {
        let prefix: String
        switch network {
        case .ethereum:
            prefix = "eth"
        case .optimism:
            prefix = "optimism"
        case .zora:
            prefix = "zora"
        case .base:
            prefix = "base"
        case .pgn:
            prefix = "pgn"
        }
        return URL(string: "https://zora.co/collect/\(prefix):\(metadata.collectionAddress)/\(metadata.tokenId)")
    }
    
}
