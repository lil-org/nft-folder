// ∅ 2026 lil org

import Foundation

struct MinimalTokenMetadata: Codable {
    
    let tokenId: String
    let collectionAddress: String
    let chain: Chain?
    let network: Network
    var dowloadedFileSourceURL: URL?
    
}
