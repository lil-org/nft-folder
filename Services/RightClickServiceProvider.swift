// ∅ 2025 lil org

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
                } else {
                    showNoNftAlert()
                }
            }
        }
    }
    
    func showNoNftAlert() {
        Alerts.showSomethingWentWrong()
    }
    
}
