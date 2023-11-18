// nft-folder-macos 2023 ethistanbul

import Cocoa

extension URL {
    
    static var nftDirectory: URL? {
        let fileManager = FileManager.default
        let downloadsDirectoryURL = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first
        guard let nftDirectoryURL = downloadsDirectoryURL?.appendingPathComponent("⌐◨-◨ ☁️") else { return nil }
        
        if !fileManager.fileExists(atPath: nftDirectoryURL.path) {
            try? fileManager.createDirectory(at: nftDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return nftDirectoryURL
    }
    
}

