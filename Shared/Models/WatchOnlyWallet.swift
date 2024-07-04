// ∅ nft-folder 2024

import Foundation
import SwiftUI

struct WatchOnlyWallet: Codable, Hashable, Identifiable {
    
    var id: String { address + (projectId ?? "") }
    
    let address: String
    let name: String?
    let avatar: String?
    let projectId: String?
    let chain: Chain?
    
    let collections: [CollectionInfo]?
    
    var listDisplayName: String {
        if let collectionName = collections?.first?.name {
            return collectionName
        } else if let name = name {
            return name
        } else {
            let cropped = address.prefix(6) + "…" + address.suffix(4)
            return String(cropped)
        }
    }
    
    var isCollection: Bool {
        return collections?.first != nil
    }
    
    var isArtBlocks: Bool {
        if let projectId = projectId, !projectId.isEmpty {
            return !projectId.contains(where: { $0.isLetter })
        } else {
            return false
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
