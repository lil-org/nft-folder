// nft-folder-macos 2023 ethistanbul

import Foundation

struct NFTService {
    
    private init() {}
    static let shared = NFTService()
    private let urlSession = URLSession.shared
    
    func getNFTs(address: String) {
        let apiKey = ""
        let limit = 10
        let offset = 0
        let urlString = "https://api.1inch.dev/nft/v1/byaddress?chainIds=1&address=\(address)&limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let task = urlSession.dataTask(with: request) { data, _, _ in
            guard let data = data else { return } // TODO: retry or something
            if let result = String(data: data, encoding: .utf8) {
                print(result)
            }
        }
        task.resume()
    }
    
}
