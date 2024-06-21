// ∅ nft-folder 2024

import Foundation

// https://github.com/lil-org/how-to-sync-nft-folders

struct Snapshot: Codable {
    let folders: [Folder]
    let uuid: String
    var cid: String?
}

struct Folder: Codable {
    let name: String
    let tokens: [Token]
    let description: String?
    let cover: String?
}

struct Token: Codable, Hashable {
    let id: String
    let address: String
    let chainId: String
    let comment: String?
}

struct RemainingFoldersForTokens: Codable {
    let dict: [Token: [String]]
}
