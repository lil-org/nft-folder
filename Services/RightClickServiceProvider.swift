// ∅ 2025 lil org

import Cocoa

class RightClickServiceProvider: NSObject {
    
    private var alertDismissDate: Date?
    
    @objc func rightClickNftFile(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
            processUrls(urls)
        }
    }
    
    private func processUrls(_ urls: [URL]) {
        if let alertDismissDate = alertDismissDate, Date().timeIntervalSince(alertDismissDate) < 1 {
            return
        }
        
        let fileManager = FileManager.default
        for url in urls {
            if url.isWithinNftDirectory {
                Navigator.shared.show(filePath: url.path, on: .opensea)
            } else {
                if url.hasDirectoryPath {
                    if let children = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil), !children.isEmpty, urls.count == 1 {
                        processUrls(children)
                        return
                    } else {
                        continue
                    }
                } else {
                    showNoNftAlert()
                }
            }
        }
    }
    
    func showNoNftAlert() {
        Alerts.showMessageAlert(Strings.thisWorksForFilesInsideNftFolder)
        if let nftDirectory = URL.nftDirectory {
            NSWorkspace.shared.open(nftDirectory)
        }
        alertDismissDate = Date()
    }
    
}
