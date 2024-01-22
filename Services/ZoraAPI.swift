// nft-folder-macos 2024

import Foundation

struct ZoraAPI {
    
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
        print("requesting zora api \(String(describing: endCursor)) NETWORKS \(networks.first?.rawValue ?? "???")")
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
                 pagination: {limit: 20\(endString)},
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
    
    func nftURL(network: Network) -> URL? {
        let prefix: String
        switch network {
        case .ethereum:
            prefix = "eth"
        case .optimism:
            prefix = "optimism"
        case .zora:
            prefix = "zora"
        case .base:
            prefix = "base"
        case .pgn:
            prefix = "pgn"
        }
        return URL(string: "https://zora.co/collect/\(prefix):\(collectionAddress)/\(tokenId)")
    }
    
    var fileDisplayName: String {
        if let name = name, let collectionName = collectionName, name.localizedCaseInsensitiveContains(collectionName) {
            return name
        } else {
            return "\(collectionName ?? "untitled") - \(name ?? tokenId)"
        }
    }
    
    var mimeType: String? {
        return nil // TODO: implement
    }
    
}
