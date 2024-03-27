// ∅ nft-folder-macos 2024

import Foundation

struct ZoraApi {
    
    private static let urlSession = URLSession.shared
    private static let queue = DispatchQueue(label: "\(Bundle.hostBundleId).ZoraApi", qos: .default)
    
    static func get(owner: String, networks: [Network], endCursor: String?, completion: @escaping (ZoraResponseData?) -> Void) {
        let kind = ZoraRequest.Kind.owner(address: owner)
        get(kind: kind, networks: networks, sort: .none, endCursor: endCursor, retryCount: 0, completion: completion)
    }
    
    static func get(collection: String, networks: [Network], endCursor: String?, completion: @escaping (ZoraResponseData?) -> Void) {
        let kind = ZoraRequest.Kind.collection(address: collection)
        get(kind: kind, networks: networks, sort: .none, endCursor: endCursor, retryCount: 0, completion: completion)
    }
    
    static func checkIfCollection(address: String, completion: @escaping (ZoraResponseData?) -> Void) {
        let kind = ZoraRequest.Kind.checkIfCollection(address: address)
        get(kind: kind, networks: Network.allCases, sort: .none, endCursor: nil, retryCount: 0, completion: completion)
    }
    
    static private func get(kind: ZoraRequest.Kind, networks: [Network], sort: ZoraRequest.Sort, endCursor: String?, retryCount: Int, completion: @escaping (ZoraResponseData?) -> Void) {
        let query = ZoraRequest.query(kind: kind, sort: sort, networks: networks, endCursor: endCursor)
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
