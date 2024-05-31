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
        for url in urls {
            if url.isWithinNftDirectory {
                Navigator.shared.show(filePath: url.path, on: .zora)
            } else {
                if url.hasDirectoryPath {
                    if let children = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil), !children.isEmpty, urls.count == 1 {
                        processUrls(children)
                        return
                    } else {
                        continue
                    }
                } else if let attributes = try? fileManager.attributesOfItem(atPath: url.path), let fileSize = attributes[.size] as? NSNumber {
                    guard fileSize.intValue < Int.defaultFileSizeLimit else {
                        showErrorAlert(fileURL: url, withRetry: false)
                        return
                    }
                    sendIt(fileURL: url)
                }
            }
        }
    }
    
    private func sendIt(fileURL: URL) {
        IpfsUploader.upload(fileURL: fileURL) { [weak self] cid in
            if let cid = cid, let url = URL(string: "https://zora.co/create?image=ipfs://\(cid)") {
                NSWorkspace.shared.open(url)
            } else {
                self?.showErrorAlert(fileURL: fileURL, withRetry: true)
            }
        }
    }
    
    func showErrorAlert(fileURL: URL, withRetry: Bool) {
        let alert = NSAlert()
        alert.messageText = Strings.didNotUpload
        alert.informativeText = fileURL.lastPathComponent
        alert.alertStyle = .warning
        if withRetry {
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
        } else {
            _ = alert.runModal()
        }
    }
    
}
