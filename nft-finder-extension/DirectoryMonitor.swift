// ∅ nft-folder-macos 2024

import Cocoa

class DirectoryMonitor {
    
    private let directoryURL: URL
    private var fileDescriptor: CInt = -1
    private var source: DispatchSourceFileSystemObject?

    init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }

    func startMonitoring() {
        guard fileDescriptor == -1 else { return }
        fileDescriptor = open(directoryURL.path, O_EVTONLY)
        guard fileDescriptor != -1 else { return }
        source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: DispatchQueue.main)
        let urlToMonitor = directoryURL
        
        source?.setEventHandler {
            let fileManager = FileManager.default
            do {
                _ = try fileManager.contentsOfDirectory(at: urlToMonitor, includingPropertiesForKeys: nil)
                HostAppMessenger.somethingChangedInHomeDirectory()
            } catch { }
        }

        let fileDescriptorToClose = fileDescriptor
        source?.setCancelHandler { [weak self] in
            close(fileDescriptorToClose)
            self?.fileDescriptor = -1
            self?.source = nil
        }

        source?.resume()
    }
    
}
