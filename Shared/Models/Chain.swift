// ∅ 2025 lil org

import Foundation

enum Chain: String, Codable {
    case ethereum, base, zora, optimism
    
    var network: Network {
        switch self {
        case .ethereum:
            return .mainnet
        case .base:
            return .base
        case .optimism:
            return .optimism
        case .zora:
            return .zora
        }
    }
    
    var nextToTry: Chain? {
        switch self {
        case .ethereum:
            return .base
        case .base:
            return .zora
        case .zora:
            return .optimism
        case .optimism:
            return nil
        }
    }
    
}
