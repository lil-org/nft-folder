// ∅ nft-folder-macos 2024

import Cocoa

class FileDownloader {
    
    private enum DownloadFileResult {
        case success, cancel, failure
    }
    
    static let shared = FileDownloader()
    
    private init() {}
    private let urlSession = URLSession.shared
    
    private var downloadsDict = [URL: (URL, String, MinimalTokenMetadata, [DataOrUrl])]() // TODO: dev tmp
    // TODO: this dict might prevent downloading the same files in some cases. make this logic explicit
    
    private var downloadsInProgress = 0
    
    func downloadFiles(wallet: WatchOnlyWallet, downloadables: [NftToDownload], network: Network) {
        guard let destination = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        for downloadable in downloadables {
            let dataOrURLs = downloadable.probableDataOrUrls
            let metadata = MinimalTokenMetadata(tokenId: downloadable.tokenId, collectionAddress: downloadable.collectionAddress, network: network)
            process(dataOrURLs: dataOrURLs, metadata: metadata, name: downloadable.fileDisplayName, destination: destination)
        }
        downloadNextIfNeeded()
    }
    
    private func process(dataOrURLs: [DataOrUrl], metadata: MinimalTokenMetadata, name: String, destination: URL) {
        guard !dataOrURLs.isEmpty else { return }
        switch dataOrURLs[0] {
        case .data(let data, let fileExtension):
            save(name: name, metadata: metadata, data: data, fileExtension: fileExtension, destinationURL: destination, downloadedFromURL: nil)
        case .url(let url):
            downloadsDict[url] = (destination, name, metadata, Array(dataOrURLs.dropFirst()))
        }
    }
    
    func showNFT(filePath: String, gallery: WebGallery) {
        if let nftURL = MetadataStorage.nftURL(filePath: filePath, gallery: gallery) {
            DispatchQueue.main.async {
                NSWorkspace.shared.open(nftURL)
            }
        }
    }
    
    private func downloadNextIfNeeded() {
        guard downloadsInProgress < 23 else { return }
        guard let (url, (destination, name, metadata, dataOrURLs)) = downloadsDict.first else { return }
        downloadsDict.removeValue(forKey: url)
        downloadsInProgress += 1
        downloadFile(name: name, metadata: metadata, from: url, to: destination) { [weak self] result in
            self?.downloadsInProgress -= 1
            switch result {
            case .success:
                self?.downloadNextIfNeeded()
            case .failure:
                if !dataOrURLs.isEmpty {
                    print("⭐️ will retry and get a fallback content for \(name)")
                    self?.process(dataOrURLs: dataOrURLs, metadata: metadata, name: name, destination: destination)
                }
                self?.downloadNextIfNeeded()
            case .cancel:
                self?.downloadNextIfNeeded() // TODO: clean up for a removed filder
            }
        }
        downloadNextIfNeeded()
    }
    
    private func downloadFile(name: String, metadata: MinimalTokenMetadata, from url: URL, to destinationURL: URL, completion: @escaping (DownloadFileResult) -> Void) {
        let task = urlSession.downloadTask(with: url) { location, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard let location = location, error == nil, (200...299).contains(statusCode) else {
                print("Status code \(statusCode). Error downloading file: \(String(describing: error))")
                completion(.failure)
                return
            }
            guard FileManager.default.fileExists(atPath: destinationURL.path) else {
                // if there is no folder anymore
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
            self.save(name: name, metadata: metadata, tmpLocation: location, fileExtension: fileExtension, destinationURL: destinationURL, downloadedFromURL: url)
            completion(.success)
        }
        task.resume()
    }
    
    private func extractValueFromJson(jsonData: Data) -> DataOrUrl? {
        if let inlineContentJSON = try? JSONDecoder().decode(InlineContentJSON.self, from: jsonData),
           let inlineDataString = inlineContentJSON.dataString,
           let dataOrURL = DataOrUrl(urlString: inlineDataString) {
            return dataOrURL
        }
        
        guard let jsonStringRaw = String(data: jsonData, encoding: .utf8), !jsonStringRaw.isEmpty else { return nil }
        
        let jsonString = jsonStringRaw.removingPercentEncoding ?? jsonStringRaw
        for key in ["animation_url", "image", "svg_image_data", "image_data"] {
            if let rangeOfKey = jsonString.range(of: "\"\(key)\"") {
                var start = jsonString.index(rangeOfKey.upperBound, offsetBy: 1)
                while start < jsonString.endIndex, jsonString[start] != "\"" {
                    start = jsonString.index(after: start)
                }
                if start < jsonString.endIndex, jsonString[start] == "\"" {
                    var end = jsonString.index(after: start)
                    while end < jsonString.endIndex, jsonString[end] != "\"" {
                        end = jsonString.index(after: end)
                    }
                    if end < jsonString.endIndex {
                        let valueStart = jsonString.index(after: start)
                        let result = String(jsonString[valueStart..<end])
                        if let dataOrURL = DataOrUrl(urlString: result) {
                            return dataOrURL
                        }
                    }
                }
            }
        }
        return nil
    }
    
    private func save(name: String, metadata: MinimalTokenMetadata, tmpLocation: URL? = nil, data: Data? = nil, fileExtension: String, destinationURL: URL, downloadedFromURL: URL?) {
        if fileExtension.lowercased() == "html", let downloadedFromURL = downloadedFromURL {
            let linkString = downloadedFromURL.absoluteString
                .replacingOccurrences(of: "&", with: "&amp;")
                .replacingOccurrences(of: "\"", with: "&quot;")
                .replacingOccurrences(of: "'", with: "&apos;")
                .replacingOccurrences(of: "<", with: "&lt;")
                .replacingOccurrences(of: ">", with: "&gt;")
            let weblocContent = """
                <?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
                <plist version="1.0">
                <dict>
                    <key>URL</key>
                    <string>\(linkString)</string>
                </dict>
                </plist>
                """
            let webloc = weblocContent.data(using: .utf8)
            save(name: name, metadata: metadata, data: webloc, fileExtension: "webloc", destinationURL: destinationURL, downloadedFromURL: nil)
            if let tmpLocation = tmpLocation {
                try? FileManager.default.removeItem(at: tmpLocation)
            }
            return
        } else if fileExtension.lowercased() == "json" || fileExtension.lowercased() == "txt" {
            let mbJsonData: Data?
            if let tmpLocation = tmpLocation, let tmpData = try? Data(contentsOf: tmpLocation) {
                mbJsonData = tmpData
            } else if let data = data {
                mbJsonData = data
            } else {
                mbJsonData = nil
            }
            if let mbJsonData = mbJsonData, let dataOrURL = extractValueFromJson(jsonData: mbJsonData) {
                switch dataOrURL {
                case .data(let data, let fileExtension):
                    save(name: name, metadata: metadata, data: data, fileExtension: fileExtension, destinationURL: destinationURL, downloadedFromURL: downloadedFromURL)
                case .url(let url):
                    downloadsDict[url] = (destinationURL, name, metadata, [])
                }
                if let tmpLocation = tmpLocation {
                    try? FileManager.default.removeItem(at: tmpLocation)
                }
                return
            }
        }
        let pathExtension = "." + fileExtension
        var finalName = name.hasSuffix(pathExtension) ? name : (name.trimmingCharacters(in: .whitespacesAndNewlines) + pathExtension)
        finalName = finalName.replacingOccurrences(of: "/", with: "-")
        let destinationURL = destinationURL.appendingPathComponent(finalName)
        saveAvoidingCollisions(tmpLocation: tmpLocation, data: data, destinationURL: destinationURL, metadata: metadata)
    }
    
    private func saveAvoidingCollisions(tmpLocation: URL?, data: Data?, destinationURL: URL, metadata: MinimalTokenMetadata) {
        let fileManager = FileManager.default

        func uniqueURL(for url: URL, tmpLocation: URL?, data: Data?) -> URL {
            let fileName = url.deletingPathExtension().lastPathComponent
            let fileExtension = url.pathExtension
            let newName = fileName.contains(metadata.tokenId) ? fileName : "\(fileName) #\(metadata.tokenId)"
            var newURL = url.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension(fileExtension)
            var count = 1
            while fileManager.fileExists(atPath: newURL.path) && areFilesDifferent(url1: newURL, url2: tmpLocation, data: data) {
                newURL = url.deletingLastPathComponent().appendingPathComponent("\(newName) \(count)").appendingPathExtension(fileExtension)
                count += 1
            }
            return newURL
        }

        func areFilesDifferent(url1: URL, url2: URL?, data: Data?) -> Bool {
            guard let fileAttributes = try? fileManager.attributesOfItem(atPath: url1.path),
                  let fileSize = fileAttributes[.size] as? NSNumber else { return true }
            
            if let data = data {
                if fileSize.intValue != data.count { return true }
                guard let fileData = try? Data(contentsOf: url1) else { return true }
                return fileData != data
            } else if let url2 = url2 {
                guard let file2Attributes = try? fileManager.attributesOfItem(atPath: url2.path),
                      let file2Size = file2Attributes[.size] as? NSNumber else { return true }
                if fileSize.int64Value != file2Size.int64Value { return true }
                guard let fileData = try? Data(contentsOf: url1) else { return true }
                guard let file2Data = try? Data(contentsOf: url2) else { return true }
                return fileData != file2Data
            } else {
                return true
            }
        }

        var finalDestinationURL = destinationURL
        do {
            if let tmpLocation = tmpLocation {
                if fileManager.fileExists(atPath: destinationURL.path), areFilesDifferent(url1: destinationURL, url2: tmpLocation, data: nil) {
                    finalDestinationURL = uniqueURL(for: destinationURL, tmpLocation: tmpLocation, data: nil)
                }
                try fileManager.moveItem(at: tmpLocation, to: finalDestinationURL)
            } else if let data = data {
                if fileManager.fileExists(atPath: destinationURL.path) && areFilesDifferent(url1: destinationURL, url2: nil, data: data) {
                    finalDestinationURL = uniqueURL(for: destinationURL, tmpLocation: nil, data: data)
                }
                try data.write(to: finalDestinationURL)
            } else {
                return
            }
        } catch {
            print("error saving file: \(error)")
        }
        
        MetadataStorage.store(metadata: metadata, filePath: finalDestinationURL.path)
    }
    
}
