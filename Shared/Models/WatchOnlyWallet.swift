// ∅ nft-folder 2024

import Foundation
import SwiftUI

struct WatchOnlyWallet: Codable, Hashable, Identifiable {
    
    var id: String { address }
    
    let address: String
    let name: String?
    let avatar: String?
    
    let collections: [CollectionInfo]?
    
    var listDisplayName: String {
        if let name = name {
            return name
        } else {
            let clean = address.dropFirst(2)
            let cropped = clean.prefix(4) + "…" + clean.suffix(4)
            return String(cropped)
        }
    }
    
    var folderDisplayName: String {
        if let name = name {
            return name
        } else {
            return address
        }
    }
    
}
