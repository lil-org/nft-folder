// nft-folder-macos 2023 ethistanbul

import Cocoa

extension URL {
    
    static let ipfsScheme = "ipfs://"
    static let arScheme = "ar://"
    static let deeplinkScheme = "nft-folder://"
    
    static func withProbableFile(urlString: String?) -> URL? {
        guard let urlString = urlString else { return nil }
        
        if urlString.hasPrefix(URL.ipfsScheme) {
            return URL(string: "https://ipfs.io/ipfs/" + urlString.dropFirst(URL.ipfsScheme.count))
        } else if urlString.hasPrefix(URL.arScheme) {
            return URL(string: "https://arweave.net/" + urlString.dropFirst(URL.arScheme.count))
        } else {
            return URL(string: urlString)
        }
    }
    
    static func nftDirectory(wallet: WatchOnlyWallet, createIfDoesNotExist: Bool) -> URL? {
        let fileManager = FileManager.default
        guard let addressDirectoryURL = nftDirectory?.appendingPathComponent(wallet.displayName) else { return nil }
        if !fileManager.fileExists(atPath: addressDirectoryURL.path) {
            if createIfDoesNotExist {
                try? fileManager.createDirectory(at: addressDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } else {
                return nil
            }
        }
        return addressDirectoryURL
    }
    
    static var nftDirectory: URL? {
        let fileManager = FileManager.default
        let musicDirectoryURL = fileManager.urls(for: .musicDirectory, in: .userDomainMask).first
        guard let nftDirectoryURL = musicDirectoryURL?.appendingPathComponent("nft") else { return nil }
        
        if !fileManager.fileExists(atPath: nftDirectoryURL.path) {
            try? fileManager.createDirectory(at: nftDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return nftDirectoryURL
    }
    
}

