// nft-folder-macos 2023

import Foundation

struct ZoraAPI {
    
    enum Network: String {
        case ethereum, optimism, zora, base, pgn
        
        private var networkStringValue: String {
            return rawValue.uppercased()
        }
        
        private var chainStringValue: String {
            let mainnet = "MAINNET"
            switch self {
            case .ethereum:
                return mainnet
            default:
                return networkStringValue + "_" + mainnet
            }
        }
        
        var query: String {
            return "{network: \(networkStringValue), chain: \(chainStringValue)}"
        }
    }
    
    private static let urlSession = URLSession.shared
    
    static func get(owner: String, networks: [Network], endCursor: String?, completion: @escaping (TokensData?) -> Void) {
        let whereString = "{ownerAddresses: [\"\(owner)\"]}"
        get(whereString: whereString, networks: networks, endCursor: endCursor, completion: completion)
    }
    
    static func get(collection: String, networks: [Network], endCursor: String?, completion: @escaping (TokensData?) -> Void) {
        let whereString = "{collectionAddresses: [\"\(collection)\"]}"
        get(whereString: whereString, networks: networks, endCursor: endCursor, completion: completion)
    }
    
    static private func get(whereString: String, networks: [Network], endCursor: String?, completion: @escaping (TokensData?) -> Void) {
        print("requesting zora api \(String(describing: endCursor))")
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
                 pagination: {limit: 50\(endString)},
                 sort: {sortKey: MINTED, sortDirection: ASC},
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
                print("ZORA API Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
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
    
    var openseaURL: URL? {
        return URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ") // TODO: implement
    }
    
    var fileDisplayName: String {
        return "\(collectionName ?? "untitled") - \(name ?? tokenId)"
    }
    
    var mimeType: String? {
        return nil // TODO: implement
    }
    
}
