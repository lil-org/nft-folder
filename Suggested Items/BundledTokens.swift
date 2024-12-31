// ∅ 2025 lil org

import Foundation

struct BundledTokens: Codable {
    
    struct Item: Codable {
        let id: String
        let name: String?
        let url: String?
        let sh: String?
        let hash: String?
    }
    
    let isComplete: Bool
    let items: [Item]
    
}
