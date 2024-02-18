// ∅ nft-folder-macos 2024

import Foundation

struct ZoraResponse: Codable {
    let data: TokensResponse
}

struct TokensResponse: Codable {
    let tokens: TokensData
}

struct TokensData: Codable {
    let pageInfo: PageInfo
    let nodes: [Node]
}

struct PageInfo: Codable {
    let endCursor: String?
    let hasNextPage: Bool
}

struct Node: Codable {
    let token: Token
}

struct Token: Codable {
    let tokenId: String
    let name: String?
    let owner: String?
    let collectionName: String?
    let collectionAddress: String
    let image: Media?
    let content: Media?
    let tokenUrl: String?
    let tokenStandard: String?
}

struct Media: Codable {
    let url: String?
    let mimeType: String?
    let mediaEncoding: Encoding?
    let size: String?
    
    struct Encoding: Codable {
        let original: String?
        let thumbnail: String?
    }
}

extension Token: NftToDownload {
    
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

struct InlineContentJSON: Decodable {
    
    private let animationURL: String?
    private let image: String?
    private let svgImageData: String?
    private let imageData: String?
    
    var dataString: String? {
        return animationURL ?? image ?? svgImageData ?? imageData
    }
    
    enum CodingKeys: String, CodingKey {
        case animationURL = "animation_url"
        case image = "image"
        case svgImageData = "svg_image_data"
        case imageData = "image_data"
    }
    
}
