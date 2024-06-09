// ∅ nft-folder 2024

import Foundation

struct Snapshot: Codable {
    let folders: [Folder]
    let uuid: String
}

struct Folder: Codable {
    let name: String
    let tokens: [Token]
}

struct Token: Codable, Hashable {
    let id: String
    let address: String
    let chainId: String
}
