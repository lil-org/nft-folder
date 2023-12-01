// nft-folder-macos 2023

import Cocoa

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
            guard let dataOrURL = downloadable.probableDataOrURL, let openseaURL = downloadable.openseaURL else { continue }
            switch dataOrURL {
            case .data(let data, let fileExtension):
                save(name: downloadable.fileDisplayName, nftURL: openseaURL, data: data, fileExtension: fileExtension, destinationURL: destination)
            case .url(let url):
                dict[url] = (downloadable.fileDisplayName, openseaURL)
            }
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
                print("Error downloading file: \(String(describing: error))")
                completion(.failure)
                return
            }
            guard FileManager.default.fileExists(atPath: destinationURL.path) else {
                completion(.cancel) // TODO: review cancel logic
                return
            }
            var fileExtension = url.pathExtension
            if fileExtension.isEmpty {
                if let httpResponse = response as? HTTPURLResponse, let mimeType = httpResponse.mimeType {
                    fileExtension = FileExtension.forMimeType(mimeType)
                } else {
                    fileExtension = FileExtension.placeholder
                }
            }
            save(name: name, nftURL: opensea, tmpLocation: location, fileExtension: fileExtension, destinationURL: destinationURL)
            completion(.success)
        }
        task.resume()
    }
    
    private func save(name: String, nftURL: URL, tmpLocation: URL? = nil, data: Data? = nil, fileExtension: String, destinationURL: URL) {
        let pathExtension = "." + fileExtension
        var finalName = name.hasSuffix(pathExtension) ? name : (name + pathExtension)
        finalName = finalName.replacingOccurrences(of: "/", with: "-")
        let destinationURL = destinationURL.appendingPathComponent(finalName)
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL) // TODO: review file exists logic
            }
            
            if let tmpLocation = tmpLocation {
                try FileManager.default.moveItem(at: tmpLocation, to: destinationURL)
            } else if let data = data {
                try data.write(to: destinationURL)
            } else {
                return
            }
            
            if let fileId = fileId(fileURL: destinationURL) {
                Storage.store(fileId: fileId, url: nftURL)
            }
        } catch {
            print("Error saving file: \(error)")
        }
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
