// nft-folder-macos 2023 ethistanbul

import Foundation

struct Storage {
    
    private static let defaults = UserDefaults.standard
    
    static func store(fileId: String, url: URL) {
        defaults.setValue(url, forKey: fileId)
    }
    
    static func opensea(fileId: String) -> URL? {
        defaults.url(forKey: fileId)
    }
    
}
