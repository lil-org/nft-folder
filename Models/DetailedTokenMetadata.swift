// ∅ nft-folder-macos 2024

import Foundation

// TODO: implement with more links, more data
struct DetailedTokenMetadata: Codable {
    
    let name: String?
    let collectionName: String?
    let tokenUrl: String?
    
}

// TODO: implement as a part of DetailedTokenMetadata
extension Token {
    
    // TODO: replace with explicit logic depending on file type and user preferences
    var probableDataOrUrls: [DataOrUrl] {
        let mapped = [content?.url, image?.url, image?.mediaEncoding?.thumbnail, tokenUrl].compactMap { (link) -> DataOrUrl? in
            if let dataOrURL = DataOrUrl(urlString: link) {
                return dataOrURL
            } else {
                return nil
            }
        }
        return mapped
    }
    
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
    
}
