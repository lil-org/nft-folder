// ∅ 2025 lil org

import Foundation

struct RawNftsApi {
    
    private static let urlSession = URLSession.shared
    private static let queue = DispatchQueue(label: "\(Bundle.hostBundleId).RawNftsApi", qos: .default)
    
    static func get(owner: String, nextCursor: String?, retryCount: Int = 0, completion: @escaping (NftsResponse?) -> Void) {
        guard let url = URL(string: "https://api.opensea.io/api/v2/chain/ethereum/account/\(owner)/nfts") else {
            completion(nil)
            return
        }
        
        let apiKey = Secrets.openSea ?? ""        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "x-api-key": apiKey
        ]
        let task = urlSession.dataTask(with: request) { data, response, error in
            let maxRetryCount = 3
            guard let data = data, error == nil, let nftsResponse = try? JSONDecoder().decode(NftsResponse.self, from: data) else {
                if retryCount > maxRetryCount {
                    completion(nil)
                } else {
                    queue.asyncAfter(deadline: .now() + .seconds(retryCount + 1)) {
                        get(owner: owner, nextCursor: nextCursor, retryCount: retryCount + 1, completion: completion)
                    }
                }
                return
            }
            completion(nftsResponse)
        }
        task.resume()
    }
    
    static func get(collection: String, nextCursor: String?, completion: @escaping () -> Void) {
        // TODO: remake for opensea
    }
    
    static func checkIfCollection(address: String, completion: @escaping () -> Void) {
        // TODO: remake for opensea
    }
    
}

struct NftsResponse: Codable {
    let nfts: [OpenSeaNft]
    let next: String?
}

struct OpenSeaNft: Codable {
    let identifier: String
    let collection: String
    let contract: String
    let tokenStandard: String
    let name: String?
    let description: String?
    let imageUrl: String?
    let displayImageUrl: String?
    let displayAnimationUrl: String?
    let metadataUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case collection
        case contract
        case tokenStandard = "token_standard"
        case name
        case description
        case imageUrl = "image_url"
        case displayImageUrl = "display_image_url"
        case displayAnimationUrl = "display_animation_url"
        case metadataUrl = "metadata_url"
    }
}

extension OpenSeaNft {
    
    func detailedMetadata(network: Network) -> DetailedTokenMetadata {
        let rawContentRepresentations = [
            ContentRepresentation(url: displayAnimationUrl, size: nil, mimeType: nil, knownKind: .video),
            ContentRepresentation(url: imageUrl, size: nil, mimeType: nil, knownKind: .image),
            ContentRepresentation(url: displayImageUrl, size: nil, mimeType: nil, knownKind: .image),
            ContentRepresentation(url: metadataUrl, size: nil, mimeType: nil, knownKind: nil),
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
                                     collectionName: collection,
                                     collectionAddress: contract,
                                     tokenId: identifier,
                                     chain: nil,
                                     network: network,
                                     tokenStandard: tokenStandard,
                                     contentRepresentations: contentRepresentations)
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
