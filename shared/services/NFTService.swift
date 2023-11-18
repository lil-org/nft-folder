// nft-folder-macos 2023 ethistanbul

import Foundation

var uniqueIds = Set<Int>() // TODO: tmp

struct NFTService {
    
    private struct Response: Decodable {
        let assets: [Asset]
    }
    
    private init() {
        if let environmentApiKey = ProcessInfo.processInfo.environment["1inch-api-key"] {
            self.apiKey = environmentApiKey
        } else {
            self.apiKey = ""; if apiKey.isEmpty { fatalError("get api key at https://portal.1inch.dev") }
        }
    }
    static let shared = NFTService()
    private let urlSession = URLSession.shared
    private let apiKey: String
    
    func study(address: String, offset: Int = 0) {
        print("will study offset \(offset)")
        getNFTs(address: address, limit: 200, offset: offset) { assets in
            print("\(assets.count) items at offset \(offset)")
            
            for asset in assets {
                uniqueIds.insert(asset.id)
            }
            
            print("uniqs count is \(uniqueIds.count)")
            
            if !assets.isEmpty {
                study(address: address, offset: offset + assets.count)
            }
        }
    }
    
    private func getNFTs(address: String, limit: Int, offset: Int, completion: @escaping ([Asset]) -> Void) {
        print("will request offset \(offset)")
        let urlString = "https://api.1inch.dev/nft/v1/byaddress?chainIds=1&address=\(address)&limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let task = urlSession.dataTask(with: request) { data, _, _ in
            if let data = data, !data.isEmpty, let response = try? JSONDecoder().decode(Response.self, from: data) {
                completion(response.assets)
            } else {
                print("it did not go well at offset \(offset)")
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    getNFTs(address: address, limit: limit, offset: offset, completion: completion)
                }
            }
        }
        task.resume()
    }
    
}
