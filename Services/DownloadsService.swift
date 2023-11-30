// nft-folder-macos 2023

import Cocoa
import UniformTypeIdentifiers

struct DownloadsService {
    
    private enum DownloadFileResult {
        case success, cancel, failure
    }
    
    static let shared = DownloadsService()
    
    private init() {}
    private let urlSession = URLSession.shared
    private let downloadQueue = DispatchQueue(label: "downloadQueue")
    
    func downloadFiles(wallet: WatchOnlyWallet, downloadables: [DownloadableNFT]) {
        guard let destination = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        var dict = [URL: (String, URL)]()
        for downloadable in downloadables {
            guard let url = downloadable.probableFileURL, let openseaURL = downloadable.openseaURL else { continue }
            dict[url] = (downloadable.fileDisplayName, openseaURL)
        }
        var isCanceled = false
        for (url, (name, opensea)) in dict {
            downloadQueue.async {
                let semaphore = DispatchSemaphore(value: 0)
                var success = false
                var retryCount = 0
                while !success && !isCanceled && retryCount < 3 {
                    downloadFile(name: name, opensea: opensea, from: url, to: destination) { result in
                        switch result {
                        case .success:
                            success = true
                        case .cancel:
                            isCanceled = true
                        case .failure:
                            retryCount += 1
                            Thread.sleep(forTimeInterval: 3)
                        }
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
    
    private func downloadFile(name: String, opensea: URL, from url: URL, to destinationURL: URL, completion: @escaping (DownloadFileResult) -> Void) {
        print("yo will download \(url)")
        let task = urlSession.downloadTask(with: url) { location, response, error in
            guard let location = location, error == nil else {
                print("Error downloading file: \(error)")
                completion(.failure)
                return
            }
            
            guard FileManager.default.fileExists(atPath: destinationURL.path) else {
                completion(.cancel)
                return
            }
            
            var pathExtension = url.pathExtension
            if pathExtension.isEmpty {
                if let httpResponse = response as? HTTPURLResponse,
                   let mimeType = httpResponse.mimeType,
                   let utType = UTType(mimeType: mimeType),
                   let fileExtension = utType.preferredFilenameExtension {
                    pathExtension = fileExtension
                } else {
                    pathExtension = "png"
                }
            }
            
            pathExtension = "." + pathExtension
            let finalName = name.hasSuffix(pathExtension) ? name : (name + pathExtension)
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
                completion(.success)
            } catch {
                print("Error saving file: \(error)")
                completion(.cancel)
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
    
}
