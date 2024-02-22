// ∅ nft-folder-macos 2024

import Cocoa

class FileDownloader {
    
    private enum DownloadFileResult {
        case success, cancel, failure
    }
    
    static let shared = FileDownloader()
    
    private init() {}
    private let urlSession = URLSession.shared
    
    private var downloadTasks = [DownloadFileTask]()
    private var downloadsInProgress = 0
    
    func addTasks(_ tasks: [DownloadFileTask]) {
        for task in tasks {
            preprocess(task: task)
        }
        downloadNextIfNeeded()
    }
    
    private func preprocess(task: DownloadFileTask) {
        switch task.currentDataOrURL {
        case .data(let data, let fileExtension):
            if !MetadataStorage.hasSomethingFor(detailedMetadata: task.detailedMetadata, addressDirectoryURL: task.destinationDirectory) {
                save(task, tmpLocation: nil, data: data, fileExtension: fileExtension)
            }
        case .url(let url):
            if let contentHash = url.fnv1aHash(),
               !MetadataStorage.has(contentHash: contentHash, addressDirectoryURL: task.destinationDirectory),
               !MetadataStorage.hasSomethingFor(detailedMetadata: task.detailedMetadata, addressDirectoryURL: task.destinationDirectory) {
                downloadTasks.append(task)
            }
        case .none:
            return
        }
    }
    
    private func downloadNextIfNeeded() {
        guard downloadsInProgress < 23 && !downloadTasks.isEmpty else { return }
        var task = downloadTasks.removeFirst()
        downloadsInProgress += 1
        downloadFile(task: task) { [weak self] result in
            self?.downloadsInProgress -= 1
            switch result {
            case .success:
                self?.downloadNextIfNeeded()
            case .failure:
                if task.willTryAnotherSource() {
                    print("⭐️ will retry and get a fallback content for \(task.fileName)")
                    self?.preprocess(task: task)
                }
                self?.downloadNextIfNeeded()
            case .cancel:
                self?.downloadNextIfNeeded() // TODO: clean up for a removed folder
            }
        }
        downloadNextIfNeeded()
    }
    
    private func downloadFile(task: DownloadFileTask, completion: @escaping (DownloadFileResult) -> Void) {
        guard let url = task.currentURL else {
            completion(.failure)
            return
        }
        
        let urlSessionDownloadTask = urlSession.downloadTask(with: url) { location, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard let location = location, error == nil, (200...299).contains(statusCode) else {
                print("Status code \(statusCode). Error downloading file: \(String(describing: error))")
                completion(.failure)
                return
            }
            guard FileManager.default.fileExists(atPath: task.destinationDirectory.path) else {
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
            
            self.save(task, tmpLocation: location, data: nil, fileExtension: fileExtension)
            completion(.success)
        }
        urlSessionDownloadTask.resume()
    }
    
    private func save(_ task: DownloadFileTask, tmpLocation: URL?, data: Data?, fileExtension: String) {
        if let redirectURL = FileSaver.shared.saveForTask(task, tmpLocation: tmpLocation, data: data, fileExtension: fileExtension) {
            var updatedTask = task
            if updatedTask.setRedirectURL(redirectURL) {
                addTasks([updatedTask])
            }
        }
    }
    
}
