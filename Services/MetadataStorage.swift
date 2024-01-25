// ∅ nft-folder-macos 2024

import Foundation

struct MetadataStorage {
    
    static func store(fileId: String, metadata: MinimalTokenMetadata) {
        // TODO: separate folder for each tracked address
        if let data = try? JSONEncoder().encode(metadata), var url = URL.metadataDirectory() {
            url.append(path: fileId)
            try? data.write(to: url)
        }
    }
    
    static func nftURL(fileId: String) -> URL? {
        if var url = URL.metadataDirectory() {
            url.append(path: fileId)
            if let data = try? Data(contentsOf: url),
               let metadata = try? JSONDecoder().decode(MinimalTokenMetadata.self, from: data) {
                return nftURL(metadata: metadata)
            }
        }
        return nil
    }
    
    private static func nftURL(metadata: MinimalTokenMetadata) -> URL? {
        let prefix: String
        switch metadata.network {
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
