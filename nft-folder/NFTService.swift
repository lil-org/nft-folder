// nft-folder-macos 2023 ethistanbul

import Foundation
import Cocoa

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
        let someURLs = assets.compactMap { $0.probableFileURL }
        var dict = [URL: (String, URL)]()
        for asset in assets {
            guard let url = asset.probableFileURL, let openseaURL = asset.openseaURL else { continue }
            dict[url] = (asset.fileDisplayName, openseaURL)
        }
        guard let destination = URL.nftDirectory(wallet: wallet) else { return }
        let downloadQueue = DispatchQueue(label: "downloadQueue")
            for (url, (name, opensea)) in dict {
                downloadQueue.async {
                    let semaphore = DispatchSemaphore(value: 0)
                    var success = false
                    while !success {
                        downloadFile(name: name, opensea: opensea, from: url, to: destination) { isSuccess in
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

    func showOpensea(filePath: String) {
        if let fileURL = URL(string: "file://" + filePath), let fileId = fileId(fileURL: fileURL), let opensea = Storage.opensea(fileId: fileId) {
            DispatchQueue.main.async {
                NSWorkspace.shared.open(opensea)
            }
        }
    }
    
    func downloadFile(name: String, opensea: URL, from url: URL, to destinationURL: URL, completion: @escaping (Bool) -> Void) {
        print("yo will download \(url)")
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                print("Error downloading file: \(error!)")
                completion(false)
                return
            }
            // TODO: remember file ids to tie these with nfts
            
            if !FileManager.default.fileExists(atPath: destinationURL.path) {
                return // TODO: cancel downloading in that case
            }
            
            let finalName = name.hasSuffix(url.pathExtension) ? name : (name + "." + url.pathExtension)
            let destinationURL = destinationURL.appendingPathComponent(finalName)
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: location, to: destinationURL)
                
                if let fileId = fileId(fileURL: destinationURL) {
                    Storage.store(fileId: fileId, url: opensea)
                }
                
                
                print("File downloaded to: \(destinationURL.path)")
                completion(true)
            } catch {
                print("Error saving file: \(error)")
                completion(false)
            }
        }
        task.resume()
    }
    
    private func fileId(fileURL: URL) -> String? {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.relativePath),
           let number = attributes[.systemFileNumber] as? UInt {
            return String(number)
        } else {
            return nil
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
