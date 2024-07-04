// ∅ nft-folder 2024

import Foundation

enum Chain: String, Codable {
    case ethereum, base
    
    var network: Network {
        switch self {
        case .ethereum:
            return .mainnet
        case .base:
            return .base
        }
    }
    
}
