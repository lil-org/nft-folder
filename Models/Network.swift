// ∅ nft-folder-macos 2024

import Foundation

enum Network: String, CaseIterable {
    
    case ethereum, optimism, zora, base, pgn
    
    private var networkStringValue: String {
        return rawValue.uppercased()
    }
    
    private var chainStringValue: String {
        let mainnet = "MAINNET"
        switch self {
        case .ethereum:
            return mainnet
        default:
            return networkStringValue + "_" + mainnet
        }
    }
    
    var query: String {
        return "{network: \(networkStringValue), chain: \(chainStringValue)}"
    }
    
}
