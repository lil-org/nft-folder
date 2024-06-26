// ∅ nft-folder 2024

import Foundation

struct SuggestedItem: Identifiable, Hashable {
    
    var id: String { address }
    
    var network: Network {
        return Network(rawValue: chainId) ?? .ethereum
    }
    
    let name: String
    let address: String
    let chainId: Int
    
}
