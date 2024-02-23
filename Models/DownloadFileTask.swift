// ∅ nft-folder-macos 2024

import Foundation

struct DownloadFileTask {
    
    let destinationDirectory: URL
    let fileName: String
    let detailedMetadata: DetailedTokenMetadata
    
    private let dataOrURLs: [DataOrUrl]
    private var sourceIndex = 0
    private var redirectURL: URL?
    
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
    
    init(destinationDirectory: URL, minimalMetadata: MinimalTokenMetadata, detailedMetadata: DetailedTokenMetadata) {
        self.destinationDirectory = destinationDirectory
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
