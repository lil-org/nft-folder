// ∅ nft-folder-macos 2024

import Foundation

struct ZoraApi {
    
    private static let urlSession = URLSession.shared
    private static let queue = DispatchQueue(label: "org.lil.nft-folder.zora", qos: .default)
    
    static func get(owner: String, networks: [Network], endCursor: String?, completion: @escaping (TokensData?) -> Void) {
        let kind = ZoraRequest.Kind.owner(address: owner)
        get(kind: kind, networks: networks, endCursor: endCursor, retryCount: 0, completion: completion)
    }
    
    static func get(collection: String, networks: [Network], endCursor: String?, completion: @escaping (TokensData?) -> Void) {
        let kind = ZoraRequest.Kind.collection(address: collection)
        get(kind: kind, networks: networks, endCursor: endCursor, retryCount: 0, completion: completion)
    }
    
    static private func get(kind: ZoraRequest.Kind, networks: [Network], endCursor: String?, retryCount: Int, completion: @escaping (TokensData?) -> Void) {
        let query = ZoraRequest.query(kind: kind, networks: networks, endCursor: endCursor)
        guard let jsonData = try? JSONSerialization.data(withJSONObject: query) else { return }
        let url = URL(string: "https://api.zora.co/graphql")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil, let zoraResponse = try? JSONDecoder().decode(ZoraResponse.self, from: data) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                if retryCount > 3 {
                    completion(nil)
                } else {
                    queue.asyncAfter(deadline: .now() + .seconds(retryCount + 1)) {
                        get(kind: kind, networks: networks, endCursor: endCursor, retryCount: retryCount + 1, completion: completion)
                    }
                }
                return
            }

            completion(zoraResponse.data.tokens)
        }

        task.resume()
    }
    
}
