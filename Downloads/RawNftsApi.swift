// ∅ 2025 lil org

import Foundation

// TODO: rewrite to use opensea api

struct RawNftsApi {
    
    private static let urlSession = URLSession.shared
    private static let queue = DispatchQueue(label: "\(Bundle.hostBundleId).RawNftsApi", qos: .default)
    
    static func get(owner: String, networks: [Network], endCursor: String?, completion: @escaping (RawNftsResponseData?) -> Void) {
        let kind = ZoraRequest.Kind.owner(address: owner)
        get(kind: kind, networks: networks, sort: .none, endCursor: endCursor, retryCount: 0, completion: completion)
    }
    
    static func get(collection: String, networks: [Network], endCursor: String?, completion: @escaping (RawNftsResponseData?) -> Void) {
        let kind = ZoraRequest.Kind.collection(address: collection)
        get(kind: kind, networks: networks, sort: .none, endCursor: endCursor, retryCount: 0, completion: completion)
    }
    
    static func checkIfCollection(address: String, completion: @escaping (RawNftsResponseData?) -> Void) {
        let kind = ZoraRequest.Kind.checkIfCollection(address: address)
        get(kind: kind, networks: Network.allCases, sort: .none, endCursor: nil, retryCount: 0, completion: completion)
    }
    
    static private func get(kind: ZoraRequest.Kind, networks: [Network], sort: ZoraRequest.Sort, endCursor: String?, retryCount: Int, completion: @escaping (RawNftsResponseData?) -> Void) {
        let shouldRequestMinimalVersion = retryCount > 1
        let query = ZoraRequest.query(kind: kind, sort: sort, networks: networks, endCursor: endCursor, minimalVersion: shouldRequestMinimalVersion)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: query) else { return }
        let url = URL(string: "https://api.zora.co/graphql")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = urlSession.dataTask(with: request) { data, response, error in
            let requireNonEmptyTokensResponse: Bool
            
            if case .collection = kind {
                requireNonEmptyTokensResponse = endCursor == nil
            } else {
                requireNonEmptyTokensResponse = false
            }
            
            let maxRetryCount = requireNonEmptyTokensResponse ? 13 : 3
            
            guard let data = data, error == nil, let zoraResponse = try? JSONDecoder().decode(ZoraResponse.self, from: data),
                  !requireNonEmptyTokensResponse || zoraResponse.data.tokens?.nodes.isEmpty == false else {
                if retryCount > maxRetryCount {
                    completion(nil)
                } else {
                    queue.asyncAfter(deadline: .now() + .seconds(retryCount + 1)) {
                        get(kind: kind, networks: networks, sort: sort, endCursor: endCursor, retryCount: retryCount + 1, completion: completion)
                    }
                }
                return
            }

            completion(zoraResponse.data)
        }

        task.resume()
    }
    
}

private struct ZoraResponse: Codable {
    let data: RawNftsResponseData
}

struct RawNftsResponseData: Codable {
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
    let token: ZoraToken
}

struct ZoraToken: Codable {
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
    }
}

extension ZoraToken {
    
    func detailedMetadata(network: Network) -> DetailedTokenMetadata {
        let rawContentRepresentations = [
            ContentRepresentation(url: content?.url, size: content?.size, mimeType: content?.mimeType, knownKind: nil),
            ContentRepresentation(url: content?.mediaEncoding?.preview ?? content?.mediaEncoding?.original, size: nil, mimeType: content?.mimeType, knownKind: nil),
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
                                     chain: nil,
                                     network: network,
                                     tokenStandard: tokenStandard,
                                     contentRepresentations: contentRepresentations)
    }
    
}

private struct ZoraRequest {
    
    enum Kind {
        case owner(address: String)
        case collection(address: String)
        case checkIfCollection(address: String)
    }
    
    enum Sort: String {
        case minted, transferred, none
        
        var query: String {
            switch self {
            case .minted, .transferred, .none:
                return rawValue.uppercased()
            }
        }
    }
    
    static func query(kind: Kind, sort: Sort, networks: [Network], endCursor: String?, minimalVersion: Bool) -> [String: String] {
        let contentQuery = minimalVersion ? "" : enabledContentQueryString
        
        let whereString: String
        switch kind {
        case .owner(let address):
            whereString = "{ownerAddresses: [\"\(address)\"]}"
        case .collection(let address), .checkIfCollection(let address):
            whereString = "{collectionAddresses: \"\(address)\"}"
        }
        let endString: String
        if let endCursor = endCursor {
            endString = ", after:\"\(endCursor)\""
        } else {
            endString = ""
        }
        let networksString = networks.map { $0.query }.joined(separator: ", ")
        
        let queryString: String
        
        switch kind {
        case .owner, .collection:
            queryString = """
            {
                tokens(
                    sort: {sortKey: \(sort.query), sortDirection: DESC},
                    networks: [\(networksString)],
                    pagination: {limit: 30\(endString)},
                    where: \(whereString)) {
                
                    pageInfo {
                        endCursor
                        hasNextPage
                    }
                
                    nodes {
                        token {
                            tokenId
                            name
                            owner
                            collectionName
                            collectionAddress
                            tokenUrl
                            tokenUrlMimeType
                            tokenStandard
                            image {
                                url
                                mimeType
                                size
                                mediaEncoding {
                                    ... on ImageEncodingTypes {
                                        original
                                        thumbnail
                                    }
                                }
                            }\(contentQuery)
                        }
                    }
                }
            }
            """
        case .checkIfCollection:
            queryString = """
            {
                collections(
                    where: \(whereString)
                    networks: [\(networksString)]
                ) {
                    nodes {
                        name
                        networkInfo {
                            chain
                            network
                        }
                    }
                }
            }
            """
        }
        
        return ["query": queryString]
    }
    
    private static let enabledContentQueryString = {
        return """
        
                        content {
                            url
                            mimeType
                            size
                            mediaEncoding {
                                ... on VideoEncodingTypes {
                                    original
                                    preview
                                }
                                ... on AudioEncodingTypes {
                                    original
                                }
                            }
                        }
        """
    }()
    
}
