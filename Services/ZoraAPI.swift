// ∅ nft-folder-macos 2024

import Foundation

struct ZoraAPI {
    
    private static let urlSession = URLSession.shared
    private static let queue = DispatchQueue(label: "org.lil.nft-folder.zora", qos: .default)
    
    static func get(owner: String, networks: [Network], endCursor: String?, completion: @escaping (TokensData?) -> Void) {
        let whereString = "{ownerAddresses: [\"\(owner)\"]}"
        get(whereString: whereString, networks: networks, endCursor: endCursor, retryCount: 0, completion: completion)
    }
    
    static func get(collection: String, networks: [Network], endCursor: String?, completion: @escaping (TokensData?) -> Void) {
        let whereString = "{collectionAddresses: [\"\(collection)\"]}"
        get(whereString: whereString, networks: networks, endCursor: endCursor, retryCount: 0, completion: completion)
    }
    
    static private func get(whereString: String, networks: [Network], endCursor: String?, retryCount: Int, completion: @escaping (TokensData?) -> Void) {
        print("requesting zora api \(String(describing: endCursor)) NETWORKS \(networks.first?.name ?? "???")")
        let endString: String
        if let endCursor = endCursor {
            endString = ", after:\"\(endCursor)\""
        } else {
            endString = ""
        }
        let networksString = networks.map { $0.query }.joined(separator: ", ")
        
        let queryString = """
        {
          tokens(networks: [\(networksString)],
                 pagination: {limit: 30\(endString)},
                 where: \(whereString))
          {
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
                image {
                  url
                  mimeType
                }
                content {
                    url
                    mimeType
                }
              }
            }
          }
        }
        """

        let query = ["query": queryString]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: query) else { return }
        let url = URL(string: "https://api.zora.co/graphql")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil, let zoraResponse = try? JSONDecoder().decode(ZoraResponse.self, from: data) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                print("ZORA API Error: \(error?.localizedDescription ?? "Unknown error") CODE: \(statusCode)")
                
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("ZORA ERROR DATA " + dataString)
                } else {
                    print("ZORA ERROR DATA NONE")
                }
                
                if retryCount == 3 {
                    completion(nil)
                } else {
                    print("ZORA API WILL RETRY")
                    queue.asyncAfter(deadline: .now() + .seconds(retryCount + 1)) {
                        get(whereString: whereString, networks: networks, endCursor: endCursor, retryCount: retryCount + 1, completion: completion)
                    }
                }
                return
            }

            completion(zoraResponse.data.tokens)
        }

        task.resume()
    }
    
}

private struct ZoraResponse: Codable {
    let data: TokensResponse
}

private struct TokensResponse: Codable {
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
}

struct Media: Codable {
    let url: String?
    let mimeType: String?
}

extension Token: DownloadableNFT {
    
    var probableDataOrURL: DataOrURL? {
        for link in [content?.url, image?.url, tokenUrl] {
            if let dataOrURL = DataOrURL(urlString: link) {
                return dataOrURL
            }
        }
        return nil
    }
    
    var fileDisplayName: String {
        if let name = name, let collectionName = collectionName, name.localizedCaseInsensitiveContains(collectionName) {
            return name
        } else {
            let collectionDisplayName: String
            if let collectionName = collectionName, !collectionName.isEmpty {
                collectionDisplayName = collectionName
            } else if collectionAddress == "0x57f1887a8bf19b14fc0df6fd9b2acc9af147ea85" {
                collectionDisplayName = "ENS"
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


// TODO: use to get fallback data
// TODO: query events for updates — there is a separate events query, events not needed within tokens query

//query MyQuery {
//  tokens(sort: {sortKey: TRANSFERRED, sortDirection: DESC}) {
//    nodes {
//      token {
//        image {
//          mediaEncoding {
//            ... on ImageEncodingTypes {
//              large
//              poster
//              original
//              thumbnail
//            }
//            ... on VideoEncodingTypes {
//              large
//              poster
//              original
//              preview
//              thumbnail
//            }
//            ... on UnsupportedEncodingTypes {
//              __typename
//              original
//            }
//            ... on AudioEncodingTypes {
//              large
//              original
//            }
//          }
//          mimeType
//          size
//          url
//        }
//        description
//        collectionName
//        collectionAddress
//        content {
//          mediaEncoding {
//            ... on ImageEncodingTypes {
//              large
//              poster
//              original
//              thumbnail
//            }
//            ... on VideoEncodingTypes {
//              large
//              poster
//              original
//              preview
//              thumbnail
//            }
//            ... on AudioEncodingTypes {
//              large
//              original
//            }
//            ... on UnsupportedEncodingTypes {
//              __typename
//              original
//            }
//          }
//          mimeType
//          size
//          url
//        }
//        lastRefreshTime
//        metadata
//        mintInfo {
//          originatorAddress
//          mintContext
//          toAddress
//          price
//        }
//        name
//        networkInfo
//        owner
//        tokenContract {
//          chain
//          collectionAddress
//          description
//          name
//          symbol
//          totalSupply
//        }
//        tokenId
//        tokenStandard
//        tokenUrl
//        tokenUrlMimeType
//      }
//      events {
//        eventType
//        properties {
//          ... on ApprovalEvent {
//            tokenId
//            approved
//            approvalEventType
//            approvedAddress
//            collectionAddress
//            ownerAddress
//          }
//          ... on MintEvent {
//            __typename
//            collectionAddress
//            originatorAddress
//            toAddress
//            tokenId
//          }
//          ... on NounsAuctionEvent {
//            __typename
//            address
//            collectionAddress
//            nounsAuctionEventType
//            properties
//          }
//          ... on Sale {
//            saleContractAddress
//            buyerAddress
//            collectionAddress
//            networkInfo
//            price
//            saleType
//            sellerAddress
//            tokenId
//            transactionInfo {
//              transactionHash
//              logIndex
//              blockTimestamp
//              blockNumber
//            }
//          }
//          ... on V3ReserveAuctionEvent {
//            __typename
//          }
//          ... on V3ModuleManagerEvent {
//            __typename
//          }
//          ... on V3AskEvent {
//            __typename
//          }
//          ... on V2AuctionEvent {
//            __typename
//          }
//          ... on V1MediaEvent {
//            __typename
//          }
//          ... on V1MarketEvent {
//            __typename
//            address
//            collectionAddress
//            properties {
//              ... on V1MarketAskCreatedEventProperties {
//                __typename
//              }
//            }
//            tokenId
//          }
//          ... on TransferEvent {
//            __typename
//            collectionAddress
//            fromAddress
//            toAddress
//            tokenId
//          }
//          ... on SeaportEvent {
//            orderHash
//            zone
//            address
//            eventType
//            offerer
//            properties {
//              ... on SeaportOrderFulfilledProperties {
//                __typename
//              }
//              ... on SeaportCounterIncrementedProperties {
//                __typename
//              }
//            }
//          }
//        }
//        networkInfo {
//          chain
//          network
//        }
//        collectionAddress
//        transactionInfo
//        tokenId
//      }
//    }
//    pageInfo
//  }
//}
