// ∅ nft-folder 2024

import Foundation

struct BundledTokens: Codable {
    
    struct Item: Codable {
        let id: String
        let name: String?
        let url: String?
        let hash: String?
    }
    
    let isComplete: Bool
    let items: [Item]
    
}
