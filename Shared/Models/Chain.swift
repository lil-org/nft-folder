// ∅ nft-folder 2024

import Foundation

enum Chain: String, Codable {
    case ethereum, solana, bitcoin, tezos, base
    
    var network: Network {
        switch self {
        case .ethereum, .solana, .bitcoin, .tezos:
            return .mainnet
        case .base:
            return .base
        }
    }
    
}
