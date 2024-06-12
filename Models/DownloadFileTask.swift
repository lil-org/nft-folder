// ∅ nft-folder 2024

import Foundation

struct DownloadFileTask {
    
    let walletRootDirectory: URL
    let fileName: String
    let detailedMetadata: DetailedTokenMetadata
    
    var hasCustomFolderName: Bool {
        return customFolderName != nil
    }
    
    var fileDestinationDirectory: URL {
        if let customFolderName = customFolderName {
            return walletRootDirectory.appending(path: customFolderName)
        } else {
            return walletRootDirectory
        }
    }
    
    private let dataOrURLs: [DataOrUrl]
    private var sourceIndex = 0
    private var redirectURL: URL?
    private var customFolderName: String?
    
    var extraCustomFolders: [String]?
    
    mutating func setCustomFolders(_ folders: [String]) {
        self.customFolderName = folders.first
        if folders.count > 1 {
            self.extraCustomFolders = Array(folders.dropFirst())
        }
    }
    
    mutating func setRedirectURL(_ url: URL) -> Bool {
        if redirectURL == nil {
            redirectURL = url
            return true
        } else {
            return false
        }
    }
    
    mutating func willTryAnotherSource() -> Bool {
        redirectURL = nil
        if sourceIndex + 1 < dataOrURLs.count {
            sourceIndex += 1
            return true
        } else {
            return false
        }
    }
    
    var currentDataOrURL: DataOrUrl? {
        if let redirectURL = redirectURL {
            return DataOrUrl.url(redirectURL)
        }
        guard dataOrURLs.count > sourceIndex else { return nil }
        return dataOrURLs[sourceIndex]
    }
    
    var currentURL: URL? {
        if case let .url(url) = currentDataOrURL {
            return url
        } else {
            return nil
        }
    }
    
    init(walletRootDirectory: URL, minimalMetadata: MinimalTokenMetadata, detailedMetadata: DetailedTokenMetadata) {
        self.walletRootDirectory = walletRootDirectory
        self.detailedMetadata = detailedMetadata
        self.fileName = detailedMetadata.fileDisplayName
        self.dataOrURLs = detailedMetadata.contentRepresentations.compactMap { content -> (DataOrUrl?) in
            if let size = content.size, !Defaults.unlimitedFileSize, size > Int.defaultFileSizeLimit {
                return nil
            } else if content.kind == .html || (!Defaults.downloadGlb && content.kind == .glb) {
                return nil
            } else {
                return content.dataOrUrl
            }
        }
    }
    
}
