// ∅ nft-folder-macos 2024

import Cocoa
import UniformTypeIdentifiers

extension URL {
    
    static let ipfsScheme = "ipfs://"
    static let arScheme = "ar://"
    static let deeplinkScheme = "nft-folder://"
    
    static func nftDirectory(wallet: WatchOnlyWallet, createIfDoesNotExist: Bool) -> URL? {
        let fileManager = FileManager.default
        guard let addressDirectoryURL = nftDirectory?.appendingPathComponent(wallet.folderDisplayName) else { return nil }
        if !fileManager.fileExists(atPath: addressDirectoryURL.path) {
            if createIfDoesNotExist {
                try? fileManager.createDirectory(at: addressDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            } else {
                return nil
            }
        }
        return addressDirectoryURL
    }
    
    // TODO: refactor
    static func detailedMetadataDirectory(wallet: WatchOnlyWallet) -> URL? {
        guard let url = nftDirectory(wallet: wallet, createIfDoesNotExist: false)?.appendingPathComponent("/.nft/detailed") else { return nil }
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        }
        return url
    }
    
    // TODO: refactor
    static func detailedMetadataDirectory(filePath: String) -> URL? {
        return metadataDirectory(filePath: filePath, path: "/.nft/detailed")
    }
    
    // TODO: refactor
    static func minimalMetadataDirectory(filePath: String) -> URL? {
        return metadataDirectory(filePath: filePath, path: "/.nft")
    }
    
    private static func metadataDirectory(filePath: String, path: String) -> URL? {
        let relativePath: Substring
        if filePath.hasPrefix(nftDirectoryPath) {
            relativePath = filePath.dropFirst(nftDirectoryPath.count)
        } else if filePath.hasPrefix(nftDirectoryPathResolved) {
            relativePath = filePath.dropFirst(nftDirectoryPathResolved.count)
        } else {
            return nil
        }
        let folderName = relativePath.prefix(while: { $0 != "/" })
        let fileManager = FileManager.default
        guard let metadataDirectoryURL = nftDirectory?.appendingPathComponent(folderName + "/.nft") else { return nil }
        if !fileManager.fileExists(atPath: metadataDirectoryURL.path) {
            try? fileManager.createDirectory(at: metadataDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        return metadataDirectoryURL
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
    
    static let nftDirectoryResolved: URL? = {
        return nftDirectory?.resolvingSymlinksInPath()
    }()
    
    static let nftDirectoryPathComponentsCount: Int = {
        return nftDirectoryResolved?.pathComponents.count ?? 0
    }()
    
    static let nftDirectoryPathResolved: String = {
        return nftDirectoryResolved?.path() ?? ""
    }()
    
    static let nftDirectoryPath: String = {
        return nftDirectory?.path() ?? ""
    }()
    
    var mimeType: String {
        if let typeIdentifier = (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier,
            let utType = UTType(typeIdentifier) {
            return utType.preferredMIMEType ?? "application/octet-stream"
        } else {
            return "application/octet-stream"
        }
    }
    
}
