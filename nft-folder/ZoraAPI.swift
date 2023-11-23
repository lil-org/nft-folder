// nft-folder-macos 2023

import Foundation

struct ZoraAPI {
    
    static func yo() {
        // Define the GraphQL query
        let queryString = """
        {
          tokens(networks: [{network: ETHEREUM, chain: MAINNET}],
                 pagination: {limit: 50},
                 sort: {sortKey: TOKEN_ID, sortDirection: ASC},
                 where: {collectionAddresses: ["0xc729Ce9bF1030fbb639849a96fA8BBD013680B64"]})
          {
            pageInfo { endCursor }
            nodes {
              token {
                tokenId
                name
                tokenUrl
                metadata
              }
            }
          }
        }
        """

        // Convert the query to JSON
        let query = ["query": queryString]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: query) else {
            print("Error: Cannot create JSON from query")
            return
        }

        // Define the URL of the GraphQL endpoint
        let url = URL(string: "https://api.zora.co/graphql")!

        // Create a URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Create a URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            // Parse the JSON data
            do {
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print(jsonObject)
                }
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }

        // Start the task
        task.resume()

    }
    
}
