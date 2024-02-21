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
    let tokenUrlMimeType: String?
    let description: String?
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
        let preview: String?
        let large: String?
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

extension Token {
    
    var detailedMetadata: DetailedTokenMetadata {
        let probableDataOrUrls = [content?.url, image?.url, image?.mediaEncoding?.thumbnail, tokenUrl].compactMap { (link) -> DataOrUrl? in
            if let dataOrURL = DataOrUrl(urlString: link) {
                return dataOrURL
            } else {
                return nil
            }
        }
        return DetailedTokenMetadata(name: name,
                                     collectionName: collectionName,
                                     collectionAddress: collectionAddress,
                                     tokenId: tokenId,
                                     tokenUrl: tokenUrl,
                                     description: description,
                                     probableDataOrUrls: probableDataOrUrls)
    }
    
}
