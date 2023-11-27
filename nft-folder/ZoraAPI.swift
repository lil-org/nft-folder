// nft-folder-macos 2023

import Foundation

struct ZoraAPI {
    
    static func yo() {
        // TODO: where: {ownerAddresses: "jacob.eth"}
        // TODO: add after: endCursor to pagination in request
        
        let queryString = """
        {
          tokens(networks: [{network: ETHEREUM, chain: MAINNET}],
                 pagination: {limit: 50},
                 sort: {sortKey: MINTED, sortDirection: ASC},
                 where: {collectionAddresses: ["0xc729Ce9bF1030fbb639849a96fA8BBD013680B64"]})
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
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
