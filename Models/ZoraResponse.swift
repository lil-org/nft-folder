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

struct Representations: Codable {
    let contentUrl: String?
    
    let contentPreviewUrl: String?
    let contentLargeUrl: String?
    
    let contentMimeType: String?
    let contentSize: String?
    
    let image: String?
    let thumbnailImage: String?
    let imageSize: String?
    
    let tokenUrl: String?
}

extension Token {
    
    func detailedMetadata(network: Network) -> DetailedTokenMetadata {
        let probableDataOrUrls = [content?.url, image?.url, image?.mediaEncoding?.thumbnail, tokenUrl].compactMap { (link) -> DataOrUrl? in
            if let dataOrURL = DataOrUrl(urlString: link) {
                return dataOrURL
            } else {
                return nil
            }
        }
        
        let representations = Representations(contentUrl: content?.url,
                                              contentPreviewUrl: content?.mediaEncoding?.preview,
                                              contentLargeUrl: content?.mediaEncoding?.large,
                                              contentMimeType: content?.mimeType,
                                              contentSize: content?.size,
                                              image: image?.url,
                                              thumbnailImage: image?.mediaEncoding?.thumbnail,
                                              imageSize: image?.size,
                                              tokenUrl: tokenUrl)
        
        return DetailedTokenMetadata(name: name,
                                     collectionName: collectionName,
                                     collectionAddress: collectionAddress,
                                     tokenId: tokenId,
                                     description: description,
                                     network: network,
                                     tokenStandard: tokenStandard,
                                     probableDataOrUrls: probableDataOrUrls,
                                     representations: representations)
    }
    
}
