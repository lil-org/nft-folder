// ∅ nft-folder-macos 2024

import Foundation

struct IPFSResponse: Codable {
    let name: String
    let hash: String
    let size: String

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case hash = "Hash"
        case size = "Size"
    }
}
