// ∅ nft-folder 2024

import Foundation

struct Snapshot: Codable {
    let folders: [Folder]
    let folderType: Int
    let formatVersion: Int
    let address: String
    let uuid: String
    let nonce: Int
    let timestamp: Int
    let metadata: String?
}

struct Folder: Codable {
    let name: String
    let tokens: [Token]
    let metadata: String?
}

struct Token: Codable {
    let chainId: String
    let tokenId: String
    let address: String
}
