// ∅ nft-folder-macos 2024

import Foundation

enum Network: Int, CaseIterable, Codable {
    
    case ethereum = 1, optimism = 10, zora = 7777777, base = 8453, arbitrum = 42161
    
    var name: String {
        switch self {
        case .ethereum:
            return "ETHEREUM"
        case .optimism:
            return "OPTIMISM"
        case .zora:
            return "ZORA"
        case .base:
            return "BASE"
        case .arbitrum:
            return "ARBITRUM"
        }
    }
    
    private var chainStringValue: String {
        let mainnet = "MAINNET"
        switch self {
        case .ethereum:
            return mainnet
        default:
            return name + "_" + mainnet
        }
    }
    
    var query: String {
        return "{network: \(name), chain: \(chainStringValue)}"
    }
    
}
