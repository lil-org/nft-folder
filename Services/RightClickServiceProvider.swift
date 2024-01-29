// ∅ nft-folder-macos 2024

import Cocoa

class RightClickServiceProvider: NSObject {
    
    @objc func rightClickMint(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], let url = urls.first {
            // TODO: implement upload and zora redirect
            print(url)
        }
    }
    
}
