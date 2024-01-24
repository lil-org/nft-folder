// ∅ nft-folder-macos 2024

import Foundation

struct MetadataStorage {
    
    // TODO: wipe defaults on a migration update
    private static let defaults = UserDefaults.standard
    
    static func store(fileId: String, url: URL) {
        let a = url.absoluteString
        // TODO: store in a separate file
    }
    
    static func nftURL(fileId: String) -> URL? {
        // TODO: read from file
        return nil
    }
    
}
