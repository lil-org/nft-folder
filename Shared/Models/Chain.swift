// ∅ nft-folder 2024

import Foundation

enum Chain: String, Codable {
    case ethereum, base, optimism, blast, zora
    
    var network: Network {
        switch self {
        case .ethereum:
            return .mainnet
        case .base:
            return .base
        case .optimism:
            return .optimism
        case .blast:
            return .blast
        case .zora:
            return .zora
        }
    }
    
}
