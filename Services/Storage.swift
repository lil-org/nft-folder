// nft-folder-macos 2024

import Foundation

struct Storage {
    
    private static let defaults = UserDefaults.standard
    
    static func store(fileId: String, url: URL) {
        let a = url.absoluteString
        defaults.setValue(a, forKey: fileId)
    }
    
    static func nftURL(fileId: String) -> URL? {
        guard let a = defaults.string(forKey: fileId), let url = URL(string: a) else { return nil }
        return url
    }
    
}
