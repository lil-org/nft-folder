// ∅ nft-folder 2024

import Cocoa

class FileDownloader: NSObject {
    
    var hasPendingTasks: Bool { FileDownloader.queue.sync { [weak self] in self?.queuedURLsHashes.isEmpty != true } }
    
    static let queue = DispatchQueue(label: "\(Bundle.hostBundleId).FileDownloader", qos: .default)
    
    private enum DownloadFileResult {
        case success, cancel, failure
    }
    
    private lazy var urlSession: URLSession? = {
        var configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15
        let delegateQueue = OperationQueue()
        delegateQueue.underlyingQueue = FileDownloader.queue
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
        return session
    }()
    
    private var ongoingTasksAndCompletions = [Int: (DownloadFileTask, (DownloadFileResult) -> Void)]()
    private var downloadTasks = [DownloadFileTask]()
    private var downloadsInProgress = 0
    private var queuedURLsHashes = Set<UInt64>()
    private var completion: () -> Void
    private var isCanceled = false
    
    private var foldersForTokens: [Token: [String]]?
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init()
    }
    
    func useFoldersForTokens(_ foldersForTokens: [Token: [String]]) {
        self.foldersForTokens = foldersForTokens
    }
    
    func invalidateAndCancel() {
        isCanceled = true
        urlSession?.invalidateAndCancel()
    }
    
    func addTasks(_ tasks: [DownloadFileTask]) {
        FileDownloader.queue.async { [weak self] in
            for task in tasks {
                self?.preprocess(task: task)
            }
            self?.downloadNextIfNeeded()
        }
    }
    
    private func preprocess(task: DownloadFileTask) {
        switch task.currentDataOrURL {
        case .data(let data, let fileExtension):
            if !MetadataStorage.hasSomethingFor(detailedMetadata: task.detailedMetadata, addressDirectoryURL: task.destinationDirectory) {
                save(task, tmpLocation: nil, data: data, fileExtension: fileExtension)
            }
        case .url(let url):
            if let contentHash = url.fnv1aHash(),
               !queuedURLsHashes.contains(contentHash),
               !MetadataStorage.has(contentHash: contentHash, addressDirectoryURL: task.destinationDirectory),
               !MetadataStorage.hasSomethingFor(detailedMetadata: task.detailedMetadata, addressDirectoryURL: task.destinationDirectory) {
                queuedURLsHashes.insert(contentHash)
                downloadTasks.append(task)
            }
        case .none:
            return
        }
    }
    
    private func downloadNextIfNeeded() {
        guard !queuedURLsHashes.isEmpty else { completion(); return }
        guard downloadsInProgress < 23 && !downloadTasks.isEmpty else { return }
        var task = downloadTasks.removeFirst()
        downloadsInProgress += 1
        downloadFile(task: task) { [weak self] result in
            if let url = task.currentURL, let contentHash = url.fnv1aHash() {
                self?.queuedURLsHashes.remove(contentHash)
            }
            
            self?.downloadsInProgress -= 1
            switch result {
            case .success:
                self?.downloadNextIfNeeded()
            case .failure:
                if self != nil, task.willTryAnotherSource() {
                    self?.preprocess(task: task)
                }
                self?.downloadNextIfNeeded()
            case .cancel:
                self?.invalidateAndCancel()
            }
        }
        downloadNextIfNeeded()
    }
    
    private func downloadFile(task: DownloadFileTask, completion: @escaping (DownloadFileResult) -> Void) {
        guard let url = task.currentURL else {
            completion(.failure)
            return
        }
        guard let urlSessionDownloadTask = urlSession?.downloadTask(with: url) else { return }
        ongoingTasksAndCompletions[urlSessionDownloadTask.taskIdentifier] = (task, completion)
        urlSessionDownloadTask.resume()
    }
    
    private func save(_ task: DownloadFileTask, tmpLocation: URL?, data: Data?, fileExtension: String) {
        // TODO: use foldersForTokens to specify folder path when needed
        if let redirectURL = FileSaver.shared.saveForTask(task, tmpLocation: tmpLocation, data: data, fileExtension: fileExtension) {
            var updatedTask = task
            if updatedTask.setRedirectURL(redirectURL) {
                addTasks([updatedTask])
            }
        }
    }
    
    deinit {
        invalidateAndCancel()
    }
    
}

extension FileDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let (task, completion) = ongoingTasksAndCompletions[downloadTask.taskIdentifier] else { return }
        ongoingTasksAndCompletions.removeValue(forKey: downloadTask.taskIdentifier)
        let statusCode = (downloadTask.response as? HTTPURLResponse)?.statusCode ?? 0
        
        guard downloadTask.error == nil, (200...299).contains(statusCode) else {
            completion(.failure)
            return
        }
        
        guard FileManager.default.fileExists(atPath: task.destinationDirectory.path) else {
            completion(.cancel)
            return
        }
        
        let fileExtension: String
        if let requestExtension = downloadTask.originalRequest?.url?.pathExtension, !requestExtension.isEmpty {
            fileExtension = requestExtension
        } else if let httpResponse = downloadTask.response as? HTTPURLResponse, let mimeType = httpResponse.mimeType {
            fileExtension = FileExtension.forMimeType(mimeType)
        } else {
            fileExtension = FileExtension.placeholder
        }
        
        save(task, tmpLocation: location, data: nil, fileExtension: fileExtension)
        completion(.success)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > Int.defaultFileSizeLimit {
            downloadTask.cancel()
            if let (_, completion) = ongoingTasksAndCompletions[downloadTask.taskIdentifier] {
                ongoingTasksAndCompletions.removeValue(forKey: downloadTask.taskIdentifier)
                completion(.failure)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        guard !isCanceled else { return }
        if error != nil, let (_, completion) = ongoingTasksAndCompletions[task.taskIdentifier] {
            ongoingTasksAndCompletions.removeValue(forKey: task.taskIdentifier)
            completion(.failure)
        }
    }
    
}
