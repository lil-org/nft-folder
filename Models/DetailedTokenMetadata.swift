// ∅ nft-folder-macos 2024

import Foundation

struct DetailedTokenMetadata: Codable {
    
    let name: String?
    let collectionName: String?
    let collectionAddress: String
    let tokenId: String
    let description: String?
    let network: Network
    let tokenStandard: String?
    
    var probableDataOrUrls: [DataOrUrl]
    let representations: Representations
    
}

extension DetailedTokenMetadata {
    
    var fileDisplayName: String {
        if let name = name, let collectionName = collectionName, name.localizedCaseInsensitiveContains(collectionName) {
            return name
        } else {
            let collectionDisplayName: String
            if let collectionName = collectionName, !collectionName.isEmpty {
                collectionDisplayName = collectionName
            } else if collectionAddress == "0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85" {
                collectionDisplayName = Strings.ens
            } else {
                collectionDisplayName = String(collectionAddress.prefix(7))
            }
            return "\(collectionDisplayName) - \(name ?? tokenId)".trimmingCharacters(in: ["."])
        }
    }
    
    func minimalMetadata(dowloadedFileSourceURL: URL? = nil) -> MinimalTokenMetadata {
        return MinimalTokenMetadata(tokenId: tokenId, collectionAddress: collectionAddress, network: network, dowloadedFileSourceURL: dowloadedFileSourceURL)
    }
    
}
