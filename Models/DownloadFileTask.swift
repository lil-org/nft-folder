// ∅ nft-folder-macos 2024

import Foundation

struct DownloadFileTask {
    
    let destinationDirectory: URL
    let fileName: String
    
    let minimalMetadata: MinimalTokenMetadata
    let detailedMetadata: DetailedTokenMetadata
    
    var sourceIndex = 0 // TODO: not sure about this one
    var currentURL: URL? // TODO: not sure about this one
    
    init(destinationDirectory: URL, minimalMetadata: MinimalTokenMetadata, detailedMetadata: DetailedTokenMetadata) {
        self.destinationDirectory = destinationDirectory
        self.minimalMetadata = minimalMetadata
        self.detailedMetadata = detailedMetadata
        self.fileName = detailedMetadata.fileDisplayName
    }
    
}
