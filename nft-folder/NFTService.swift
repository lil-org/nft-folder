// nft-folder-macos 2023 ethistanbul

import Foundation

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
    
    func study(wallet: WatchOnlyWallet, offset: Int = 0) {
        getNFTs(address: wallet.address, limit: 200, offset: offset) { assets in
            downloadSomeFiles(wallet: wallet, assets: assets)
            if !assets.isEmpty {
                study(wallet: wallet, offset: offset + assets.count)
            }
        }
    }
    
    private func downloadSomeFiles(wallet: WatchOnlyWallet, assets: [Asset]) {
        // TODO: try more different urls but only use those with a valid path extensions
        // TODO: get from infura as well
        // TODO: remember file ids to tie these with nfts
        let someURLs = assets.compactMap { $0.imageOriginalUrl?.hasPrefix("https") == true ? $0.imageOriginalUrl : nil }
        let urls = Array(Set(someURLs))
        guard let destination = URL.nftDirectory(wallet: wallet) else { return }
        let downloadQueue = DispatchQueue(label: "downloadQueue")
            for urlString in urls {
                guard let url = URL(string: urlString) else { continue }
                downloadQueue.async {
                    let semaphore = DispatchSemaphore(value: 0)
                    var success = false
                    while !success {
                        downloadFile(from: url, to: destination) { isSuccess in
                            let itsOk = true // TODO: better downloading logic
                            success = isSuccess || itsOk
                            if !success { Thread.sleep(forTimeInterval: 3) }
                            semaphore.signal()
                        }
                        semaphore.wait()
                    }
                }
            }
    }

    func downloadFile(from url: URL, to destinationURL: URL, completion: @escaping (Bool) -> Void) {
        print("yo will download \(url)")
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                print("Error downloading file: \(error!)")
                completion(false)
                return
            }
            // TODO: better name
            let destinationURL = destinationURL.appendingPathComponent(url.lastPathComponent)
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: location, to: destinationURL)
                print("File downloaded to: \(destinationURL.path)")
                completion(true)
            } catch {
                print("Error saving file: \(error)")
                completion(false)
            }
        }
        task.resume()
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
