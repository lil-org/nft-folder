// nft-folder-macos 2023 ethistanbul

import Cocoa

extension URL {
    
    static let deeplinkScheme = "nft-folder://"
    
    static var nftDirectory: URL? {
        let fileManager = FileManager.default
        let musicDirectoryURL = fileManager.urls(for: .musicDirectory, in: .userDomainMask).first
        guard let nftDirectoryURL = musicDirectoryURL?.appendingPathComponent("nft ☁️") else { return nil }
        
        if !fileManager.fileExists(atPath: nftDirectoryURL.path) {
            try? fileManager.createDirectory(at: nftDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return nftDirectoryURL
    }
    
    static func nftDirectory(address: String) -> URL? {
        let fileManager = FileManager.default
        guard let addressDirectoryURL = nftDirectory?.appendingPathComponent(address.lowercased()) else { return nil }
        if !fileManager.fileExists(atPath: addressDirectoryURL.path) {
            try? fileManager.createDirectory(at: addressDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        return addressDirectoryURL
    }
    
}

