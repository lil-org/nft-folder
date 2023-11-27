// nft-folder-macos 2023

import Foundation

struct ZoraAPI {
    
    enum Network {
        case ethereum
        // TODO: add all supported networks
        
        var networkStringValue: String {
            return "ETHEREUM"
        }
        
        var chainStringValue: String {
            return "MAINNET"
        }
    }
    
    private static let urlSession = URLSession.shared
    
    static func get(owner: String, networks: [Network], endCursor: String?) {
        let whereString = "{ownerAddresses: [\"\(owner)\"]}"
        get(whereString: whereString, networks: networks, endCursor: endCursor)
    }
    
    static func get(collection: String, networks: [Network], endCursor: String?) {
        let whereString = "{collectionAddresses: [\"\(collection)\"]}"
        get(whereString: whereString, networks: networks, endCursor: endCursor)
    }
    
    static private func get(whereString: String, networks: [Network], endCursor: String?) {
        let endString: String
        if let endCursor = endCursor {
            endString = ", after:\"\(endCursor)\""
        } else {
            endString = ""
        }
        
        let queryString = """
        {
          tokens(networks: [{network: ETHEREUM, chain: MAINNET}],
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
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonObject)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    
}
