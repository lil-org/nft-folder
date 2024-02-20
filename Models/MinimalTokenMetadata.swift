// ∅ nft-folder-macos 2024

import Foundation

struct MinimalTokenMetadata: Codable {
    
    let tokenId: String
    let collectionAddress: String
    let network: Network
    var dowloadedFileSourceURL: URL?
    
}
