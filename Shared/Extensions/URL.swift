// ∅ nft-folder 2024

import Cocoa
import UniformTypeIdentifiers

extension URL {
    
    static let ipfsScheme = "ipfs://"
    static let arScheme = "ar://"
    static let deeplinkScheme = "nft-folder://"
    
    private enum MetadataKind: String {
        case address, minimal, detailed, hashed
    }
    
    var isWithinNftDirectory: Bool {
        if path.hasPrefix(URL.nftDirectoryPathResolved) {
            return true
        } else {
            return false
        }
    }
    
    static func attestFolder(address: String, cid: String) -> URL? {
        // bafkreib3z7ghnugwo5fyu2b4neewxcrrwowg2lkkzi2jyflbmyudfwpydq
        let bytesString = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003b6261666b72656962337a3767686e7567776f356679753262346e65657778637272776f7767326c6b6b7a69326a79666c626d7975646677707964710000000000" // TODO: create with cid
        let schema = "0x39693b21ffe38b11da9ae29437c981de90e56ddb8606ead0c5460ba4a9f93880"
        let string = "https://base.easscan.org/attestation/attestWithSchema/\(schema)#template=\(address)::0:false:\(bytesString)"
        return URL(string: string)
    }
    
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
    
    static func avatarOnDisk(wallet: WatchOnlyWallet) -> URL? {
        guard let url = nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return nil }
        return metadataDirectory(walletFolderURL: url, metadataKind: .address)?.appendingPathComponent("avatar")
    }
    
    static func detailedMetadataDirectory(wallet: WatchOnlyWallet) -> URL? {
        guard let url = nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return nil }
        return metadataDirectory(walletFolderURL: url, metadataKind: .detailed)
    }
    
    static func detailedMetadataDirectory(addressDirectoryURL: URL) -> URL? {
        return metadataDirectory(walletFolderURL: addressDirectoryURL, metadataKind: .detailed)
    }
    
    static func hashedMetadataDirectory(addressDirectoryURL: URL) -> URL? {
        return metadataDirectory(walletFolderURL: addressDirectoryURL, metadataKind: .hashed)
    }
    
    static func detailedMetadataDirectory(filePath: String) -> URL? {
        return metadataDirectory(filePath: filePath, metadataKind: .detailed)
    }
    
    static func minimalMetadataDirectory(filePath: String) -> URL? {
        return metadataDirectory(filePath: filePath, metadataKind: .minimal)
    }
    
    private static func metadataDirectory(filePath: String, metadataKind: MetadataKind) -> URL? {
        let fileURL = URL(filePath: filePath).resolvingSymlinksInPath()
        guard fileURL.pathComponents.count > nftDirectoryPathComponentsCount && fileURL.path.hasPrefix(nftDirectoryPathResolved) else { return nil }
        let folderName = fileURL.pathComponents[nftDirectoryPathComponentsCount]
        guard let walletFolderURL = nftDirectory?.appendingPathComponent(folderName) else { return nil }
        return metadataDirectory(walletFolderURL: walletFolderURL, metadataKind: metadataKind)
    }
    
    private static func metadataDirectory(walletFolderURL: URL, metadataKind: MetadataKind) -> URL? {
        let fileManager = FileManager.default
        let metadataDirectoryURL = walletFolderURL.appendingPathComponent("/.nft/\(metadataKind.rawValue)")
        if !fileManager.fileExists(atPath: metadataDirectoryURL.path) {
            try? fileManager.createDirectory(at: metadataDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        return metadataDirectoryURL
    }
    
    static var nftDirectory: URL? {
        let fileManager = FileManager.default
        let musicDirectoryURL = fileManager.urls(for: .musicDirectory, in: .userDomainMask).first
        guard let nftDirectoryURL = musicDirectoryURL?.appendingPathComponent("nft folder") else { return nil }
        
        if !fileManager.fileExists(atPath: nftDirectoryURL.path) {
            try? fileManager.createDirectory(at: nftDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return nftDirectoryURL
    }
    
    private static let nftDirectoryResolved: URL? = {
        return nftDirectory?.resolvingSymlinksInPath()
    }()
    
    static let nftDirectoryPathComponentsCount: Int = {
        return nftDirectoryResolved?.pathComponents.count ?? 0
    }()
    
    private static let nftDirectoryPathResolved: String = {
        return nftDirectoryResolved?.path ?? ""
    }()
    
    var mimeType: String {
        if let typeIdentifier = (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier,
            let utType = UTType(typeIdentifier) {
            return utType.preferredMIMEType ?? "application/octet-stream"
        } else {
            return "application/octet-stream"
        }
    }
    
    func fnv1aHash() -> UInt64? {
        return absoluteString.data(using: .utf8)?.fnv1aHash()
    }
    
}
