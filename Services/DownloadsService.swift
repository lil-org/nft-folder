// nft-folder-macos 2023

import Cocoa

class DownloadsService {
    
    private enum DownloadFileResult {
        case success, cancel, failure
    }
    
    static let shared = DownloadsService()
    
    private init() {}
    private let urlSession = URLSession.shared
    
    private var downloadsDict = [URL: (URL, String, URL)]() // TODO: dev tmp
    private var downloadsInProgress = 0
    
    func downloadFiles(wallet: WatchOnlyWallet, downloadables: [DownloadableNFT], network: Network) {
        guard let destination = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        for downloadable in downloadables {
            guard let dataOrURL = downloadable.probableDataOrURL, let nftURL = downloadable.nftURL(network: network) else { continue }
            switch dataOrURL {
            case .data(let data, let fileExtension):
                save(name: downloadable.fileDisplayName, nftURL: nftURL, data: data, fileExtension: fileExtension, destinationURL: destination)
            case .url(let url):
                downloadsDict[url] = (destination, downloadable.fileDisplayName, nftURL)
            }
        }
        downloadNextIfNeeded()
    }
    
    func showNFT(filePath: String) {
        if let fileId = fileId(path: filePath), let nftURL = Storage.nftURL(fileId: fileId) {
            DispatchQueue.main.async {
                NSWorkspace.shared.open(nftURL)
            }
        }
    }
    
    private func downloadNextIfNeeded() {
        guard downloadsInProgress < 15 else { return }
        guard let (url, (destination, name, nftURL)) = downloadsDict.first else { return }
        downloadsDict.removeValue(forKey: url)
        downloadsInProgress += 1
        downloadFile(name: name, nftURL: nftURL, from: url, to: destination) { [weak self] result in
            self?.downloadsInProgress -= 1
            switch result {
            case .success, .failure:
                self?.downloadNextIfNeeded()
            case .cancel:
                self?.downloadNextIfNeeded() // TODO: clean up for a removed filder
            }
        }
        downloadNextIfNeeded()
    }
    
    private func downloadFile(name: String, nftURL: URL, from url: URL, to destinationURL: URL, completion: @escaping (DownloadFileResult) -> Void) {
        print("yo will download \(url)")
        let task = urlSession.downloadTask(with: url) { location, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            print("download completion \(url)")
            guard let location = location, error == nil, (200...299).contains(statusCode) else {
                print("Status code \(statusCode). Error downloading file: \(String(describing: error))")
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
        if let tmpLocation = tmpLocation,
           fileExtension.lowercased() == "json" || fileExtension.lowercased() == "txt",
           let mbJsonData = try? Data(contentsOf: tmpLocation),
           let dict = try? JSONSerialization.jsonObject(with: mbJsonData) as? [String: Any],
           let imageString = (dict["image"] as? String) ?? (dict["image_data"] as? String) ?? (dict["svg_image_data"] as? String),
           let dataOrURL = DataOrURL(urlString: imageString) {
            switch dataOrURL {
            case .data(let data, let fileExtension):
                save(name: name, nftURL: nftURL, data: data, fileExtension: fileExtension, destinationURL: destinationURL)
            case .url(let url):
                downloadsDict[url] = (destinationURL, name, nftURL)
            }
            try? FileManager.default.removeItem(at: tmpLocation)
            return
        }
        
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
            
            if let fileId = fileId(path: destinationURL.path) {
                Storage.store(fileId: fileId, url: nftURL)
            }
        } catch {
            print("Error saving file: \(error)")
        }
    }
    
    private func fileId(path: String) -> String? {
        if let attributes = try? FileManager.default.attributesOfItem(atPath: path),
           let number = attributes[.systemFileNumber] as? UInt {
            return String(number)
        } else {
            return nil
        }
    }
    
}
