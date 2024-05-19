// ∅ nft-folder 2024

import Cocoa

class RightClickServiceProvider: NSObject {
    
    @objc func rightClickMint(_ pasteboard: NSPasteboard, userData: String?, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL], !urls.isEmpty {
            // TODO: check if it is an existing nft
            if let url = urls.first {
                sendIt(fileURL: url)
            }
        }
    }
    
    private func sendIt(fileURL: URL) {
        let boundary = "----WebKitFormBoundaryn3JBuHDuzWcHa9BR"
        var request = URLRequest(url: URL(string: "https://ipfs-uploader.zora.co/api/v0/add?stream-channels=true&cid-version=1&progress=false")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".utf8))
        body.append(Data("Content-Type: \(fileURL.mimeType)\r\n\r\n".utf8))
        guard let fileData = try? Data(contentsOf: fileURL) else { return }
        body.append(fileData)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  error == nil,
                  let ipfsResponse = try? JSONDecoder().decode(IpfsResponse.self, from: data),
                  let url = URL(string: "https://zora.co/create?image=ipfs://\(ipfsResponse.hash)") else {
                DispatchQueue.main.async { [weak self] in
                    self?.showErrorAlert(fileURL: fileURL)
                }
                return
            }
                        
            DispatchQueue.main.async {
                NSWorkspace.shared.open(url)
            }
        }
        task.resume()
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
