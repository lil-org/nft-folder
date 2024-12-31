// ∅ 2025 lil org

import Foundation

struct GeneratedToken: Codable {
    let fullCollectionId: String
    let address: String
    let id: String
    let html: String
    let displayName: String
    let url: URL?
    let instructions: String?
    let screensaver: URL?
    
    static let empty = GeneratedToken(fullCollectionId: "", address: "", id: "", html: "", displayName: "", url: nil, instructions: nil, screensaver: nil)
}
