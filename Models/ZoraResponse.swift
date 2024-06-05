// ∅ nft-folder 2024

import Foundation

struct ZoraResponse: Codable {
    let data: ZoraResponseData
}

struct ZoraResponseData: Codable {
    let tokens: TokensData?
    let collections: CollectionsData?
}

struct CollectionsData: Codable {
    let nodes: [CollectionNode]
}

struct CollectionNode: Codable {
    let name: String
    let networkInfo: NetworkInfoResponse
}

struct NetworkInfoResponse: Codable {
    let chain: String
    let network: String
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
    
    var customImageEncoding: String? {
        if let url = url,
           url.hasPrefix(URL.ipfsScheme),
           let urlQueryEncoded = (URL.ipfsGateway + url.dropFirst(URL.ipfsScheme.count)).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let custom = "https://remote-image.decentralized-content.com/image?url=\(urlQueryEncoded)&w=1920&q=75"
            return custom
        } else {
            return nil
        }
    }
    
    struct Encoding: Codable {
        let original: String?
        let thumbnail: String?
        let preview: String?
        let large: String?
    }
}

extension Token {
    
    func detailedMetadata(network: Network) -> DetailedTokenMetadata {
        let rawContentRepresentations = [
            ContentRepresentation(url: content?.url, size: content?.size, mimeType: content?.mimeType, knownKind: nil),
            ContentRepresentation(url: content?.mediaEncoding?.preview ?? content?.mediaEncoding?.large, size: nil, mimeType: content?.mimeType, knownKind: nil),
            ContentRepresentation(url: image?.url, size: image?.size, mimeType: image?.mimeType, knownKind: .image),
            ContentRepresentation(url: image?.customImageEncoding, size: nil, mimeType: image?.mimeType, knownKind: .image),
            ContentRepresentation(url: image?.mediaEncoding?.thumbnail, size: nil, mimeType: image?.mimeType, knownKind: .image),
            ContentRepresentation(url: tokenUrl, size: nil, mimeType: tokenUrlMimeType, knownKind: nil)
        ]
        
        var contentRepresentations = [ContentRepresentation]()
        var hasDataRepresentation = false
        for item in rawContentRepresentations {
            guard let item = item else { continue }
            switch item.dataOrUrl {
            case .data:
                if !hasDataRepresentation {
                    hasDataRepresentation = true
                    contentRepresentations.append(item)
                }
            case .url:
                if !contentRepresentations.contains(where: { $0.dataOrUrl == item.dataOrUrl }) {
                    contentRepresentations.append(item)
                }
            }
        }
        
        return DetailedTokenMetadata(name: name,
                                     collectionName: collectionName,
                                     collectionAddress: collectionAddress,
                                     tokenId: tokenId,
                                     network: network,
                                     tokenStandard: tokenStandard,
                                     contentRepresentations: contentRepresentations)
    }
    
}
