// ∅ 2025 lil org

import Foundation

// https://github.com/lil-org/how-to-sync-nft-folders

struct Snapshot: Codable {
    let folders: [Folder]
    let uuid: String
    var cid: String?
}

enum FolderType: UInt32 {
    case organized = 42
    case curated = 69
    
    var dataPrefix: String {
        switch self {
        case .organized:
            return "0x000000000000000000000000000000000000000000000000000000000000002a"
        case .curated:
            return "0x0000000000000000000000000000000000000000000000000000000000000045"
        }
    }
}

struct Folder: Codable {
    let name: String
    let tokens: [Token]
    let description: String?
    let cover: String?
}

struct Token: Codable {
    let id: String
    let address: String
    let chainId: String
    let comment: String?
}

extension Token: Hashable {
    static func == (lhs: Token, rhs: Token) -> Bool {
        return lhs.id == rhs.id &&
               lhs.address == rhs.address &&
               lhs.chainId == rhs.chainId
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(address)
        hasher.combine(chainId)
    }
}

struct RemainingFoldersForTokens: Codable {
    let dict: [Token: [String]]
}
