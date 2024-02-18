// ∅ nft-folder-macos 2024

import Foundation

struct ZoraApi {
    
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
        let query = ZoraRequest.query(whereString: whereString, networks: networks, endCursor: endCursor)
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
