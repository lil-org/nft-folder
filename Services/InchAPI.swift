// nft-folder-macos 2023

import Foundation

struct InchAPI {
    
    static let shared = InchAPI()
    private init() {}
    
    private struct InchResponse: Decodable {
        let assets: [InchAsset]
    }
    
    private let urlSession = URLSession.shared
    private let apiKey = Secrets.inchApiKey
    
    func getNFTs(address: String, limit: Int, offset: Int, completion: @escaping ([InchAsset]) -> Void) {
        let urlString = "https://api.1inch.dev/nft/v1/byaddress?chainIds=1&address=\(address)&limit=\(limit)&offset=\(offset)"
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        let task = urlSession.dataTask(with: request) { data, _, _ in
            if let data = data, !data.isEmpty, let response = try? JSONDecoder().decode(InchResponse.self, from: data) {
                completion(response.assets)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { // TODO: better retry logic
                    getNFTs(address: address, limit: limit, offset: offset, completion: completion)
                }
            }
        }
        task.resume()
    }
    
}
