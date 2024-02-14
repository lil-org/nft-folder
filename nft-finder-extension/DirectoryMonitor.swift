// ∅ nft-folder-macos 2024

import Cocoa

// TODO: review and clean up
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

        source?.setEventHandler {
            let fileManager = FileManager.default
            do {
                _ = try fileManager.contentsOfDirectory(at: self.directoryURL, includingPropertiesForKeys: nil)
                if let url = URL(string: URL.deeplinkScheme + "?check") {
                    DispatchQueue.main.async { NSWorkspace.shared.open(url) }
                }
            } catch {
                print("Error reading directory contents: \(error)")
            }
        }

        source?.setCancelHandler {
            close(self.fileDescriptor)
            self.fileDescriptor = -1
            self.source = nil
        }

        source?.resume()
    }
    
}
