// ∅ nft-folder 2024

import Foundation

struct MinimalTokenMetadata: Codable {
    
    let tokenId: String
    let collectionAddress: String
    let chain: Chain?
    let network: Network
    var dowloadedFileSourceURL: URL?
    
}
