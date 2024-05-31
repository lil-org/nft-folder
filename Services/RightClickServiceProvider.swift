// ∅ nft-folder 2024

import Cocoa

class RightClickServiceProvider: NSObject {
    
    @objc func rightClickMint(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
            processUrls(urls)
        }
    }
    
    private func processUrls(_ urls: [URL]) {
        let fileManager = FileManager.default
        
        var urlsToUpload = [URL]()
        
        for url in urls {
            if url.isWithinNftDirectory {
                Navigator.shared.show(filePath: url.path, on: .zora)
                continue
            } else {
                // TODO: filter out stuff that can't be uploaded, like big folders, etc.
                urlsToUpload.append(url)
            }
            
            if url.hasDirectoryPath, let children = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil), !children.isEmpty {
                // TODO: handle folders corresponding to existing nfts
                processUrls(children)
                return // TODO: make sure it does not go deep recursively
            }
            
            if let attributes = try? fileManager.attributesOfItem(atPath: url.path),
               let fileSize = attributes[.size] as? NSNumber {
                if fileSize.uintValue > 10485760 {
                    print("file is bigger than 10 mb")
                    showErrorAlert(fileURL: url)
                    // TODO: ask confirmation if there are big files
                    return
                }
            }
        }
        
        for url in urlsToUpload {
            sendIt(fileURL: url)
        }
    }
    
    private func sendIt(fileURL: URL) {
        IpfsUploader.upload(fileURL: fileURL) { [weak self] cid in
            if let cid = cid, let url = URL(string: "https://zora.co/create?image=ipfs://\(cid)") {
                NSWorkspace.shared.open(url)
            } else {
                self?.showErrorAlert(fileURL: fileURL)
            }
        }
    }
    
    func showErrorAlert(fileURL: URL) {
        let alert = NSAlert()
        alert.messageText = Strings.didNotUpload
        alert.informativeText = fileURL.lastPathComponent
        alert.alertStyle = .warning
        alert.addButton(withTitle: Strings.retry)
        alert.addButton(withTitle: Strings.cancel)
        alert.buttons.last?.keyEquivalent = "\u{1b}"
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            sendIt(fileURL: fileURL)
        default:
            break
        }
    }
    
}
