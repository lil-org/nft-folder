// ∅ nft-folder-macos 2024

import Foundation

struct DownloadFileTask {
    
    let destinationDirectory: URL
    let fileName: String
    
    let minimalMetadata: MinimalTokenMetadata
    let detailedMetadata: DetailedTokenMetadata
    
    private var sourceIndex = 0 // TODO: not sure about this one
    
    mutating func willTryAnotherSource() -> Bool {
        if sourceIndex + 1 < detailedMetadata.probableDataOrUrls.count {
            sourceIndex += 1
            return true
        } else {
            return false
        }
    }
    
    var currentDataOrURL: DataOrUrl? { // TODO: not sure about this one
        guard detailedMetadata.probableDataOrUrls.count > sourceIndex else { return nil }
        return detailedMetadata.probableDataOrUrls[sourceIndex]
    }
    
    var currentURL: URL? { // TODO: not sure about this one
        if case let .url(url) = currentDataOrURL {
            return url
        } else {
            return nil
        }
    }
    
    init(destinationDirectory: URL, minimalMetadata: MinimalTokenMetadata, detailedMetadata: DetailedTokenMetadata) {
        self.destinationDirectory = destinationDirectory
        self.minimalMetadata = minimalMetadata
        self.detailedMetadata = detailedMetadata
        self.fileName = detailedMetadata.fileDisplayName
    }
    
}
