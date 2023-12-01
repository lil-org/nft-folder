// nft-folder-macos 2023

import Cocoa

class DownloadsService {
    
    private enum DownloadFileResult {
        case success, cancel, failure
    }
    
    static let shared = DownloadsService()
    
    private init() {}
    private let urlSession = URLSession.shared
    private let downloadQueue = DispatchQueue(label: "downloadQueue")
    private var uniqueLinks = Set<URL>() // TODO: dev tmp
    
    func downloadFiles(wallet: WatchOnlyWallet, downloadables: [DownloadableNFT]) {
        guard let destination = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        var dict = [URL: (String, URL)]()
        for downloadable in downloadables {
            guard let dataOrURL = downloadable.probableDataOrURL, let nftURL = downloadable.nftURL else { continue }
            switch dataOrURL {
            case .data(let data, let fileExtension):
                save(name: downloadable.fileDisplayName, nftURL: nftURL, data: data, fileExtension: fileExtension, destinationURL: destination)
            case .url(let url):
                if !uniqueLinks.contains(url) {
                    uniqueLinks.insert(url)
                    dict[url] = (downloadable.fileDisplayName, nftURL)
                }
            }
        }
        var isCanceled = false
        for (url, (name, nftURL)) in dict {
            downloadQueue.async {
                let semaphore = DispatchSemaphore(value: 0)
                var success = false
                var retryCount = 0
                while !success && !isCanceled && retryCount < 2 {
                    self.downloadFile(name: name, nftURL: nftURL, from: url, to: destination) { result in
                        switch result {
                        case .success:
                            success = true
                        case .cancel:
                            isCanceled = true
                        case .failure:
                            retryCount += 1
                            Thread.sleep(forTimeInterval: 1)
                        }
                        semaphore.signal()
                    }
                    semaphore.wait()
                }
            }
        }
    }
    
    func showOpensea(filePath: String) {
        if let fileURL = URL(string: "file://" + filePath), let fileId = fileId(fileURL: fileURL), let nftURL = Storage.nftURL(fileId: fileId) {
            DispatchQueue.main.async {
                NSWorkspace.shared.open(nftURL)
            }
        }
    }
    
    private func downloadFile(name: String, nftURL: URL, from url: URL, to destinationURL: URL, completion: @escaping (DownloadFileResult) -> Void) {
        print("yo will download \(url)")
        let task = urlSession.downloadTask(with: url) { location, response, error in
            print("download completion \(url)")
            guard let location = location, error == nil else {
                print("Error downloading file: \(String(describing: error))")
                completion(.failure)
                return
            }
            guard FileManager.default.fileExists(atPath: destinationURL.path) else {
                print("cancel download")
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
            print("will save \(url)")
            self.save(name: name, nftURL: nftURL, tmpLocation: location, fileExtension: fileExtension, destinationURL: destinationURL)
            completion(.success)
            print("did save \(url)")
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
