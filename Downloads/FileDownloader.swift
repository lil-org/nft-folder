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
            save(name: name, metadata: metadata, tmpLocation: nil, data: data, fileExtension: fileExtension, destinationURL: destination, downloadedFromURL: nil)
        case .url(let url):
            downloadsDict[url] = (destination, name, metadata, Array(dataOrURLs.dropFirst()))
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
            self.save(name: name, metadata: metadata, tmpLocation: location, data: nil, fileExtension: fileExtension, destinationURL: destinationURL, downloadedFromURL: url)
            completion(.success)
        }
        task.resume()
    }
    
    private func save(name: String, metadata: MinimalTokenMetadata, tmpLocation: URL?, data: Data?, fileExtension: String, destinationURL: URL, downloadedFromURL: URL?) {
        if let url = FileSaver.shared.save(name: name, metadata: metadata, tmpLocation: tmpLocation, data: data, fileExtension: fileExtension, destinationURL: destinationURL, downloadedFromURL: downloadedFromURL) {
            downloadsDict[url] = (destinationURL, name, metadata, [])
        }
    }
    
}
