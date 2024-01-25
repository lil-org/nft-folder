// ∅ nft-folder-macos 2024

import Foundation

struct MetadataStorage {
    
    static func store(metadata: MinimalTokenMetadata, filePath: String) {
        if let fileId = fileId(path: filePath),
           let data = try? JSONEncoder().encode(metadata),
           var url = URL.metadataDirectory(filePath: filePath) {
            url.append(path: fileId)
            try? data.write(to: url)
        }
    }
    
    static func nftURL(filePath: String) -> URL? {
        if let fileId = fileId(path: filePath), var url = URL.metadataDirectory(filePath: filePath) {
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
    
    private static func fileId(path: String) -> String? {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: path),
           let number = attributes[.systemFileNumber] as? UInt {
            return String(number)
        } else {
            return nil
        }
    }
    
}
