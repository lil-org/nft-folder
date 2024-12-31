// ∅ 2025 lil org

import Foundation

struct IpfsUploader {
    
    static func upload(name: String, mimeType: String, data: Data, completion: @escaping (String?) -> Void) {
        let boundary = "----WebKitFormBoundaryn3JBuHDuzWcHa9BR"
        var request = URLRequest(url: URL(string: "https://ipfs-uploader.zora.co/api/v0/add?stream-channels=true&cid-version=1&progress=false")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"file\"; filename=\"\(name)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mimeType)\r\n\r\n".utf8))
        body.append(data)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, error == nil, let ipfsResponse = try? JSONDecoder().decode(IpfsResponse.self, from: data) {
                DispatchQueue.main.async { completion(ipfsResponse.cid) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
        task.resume()
    }
    
    static func upload(fileURL: URL, completion: @escaping (String?) -> Void) {
        guard let fileData = try? Data(contentsOf: fileURL) else { return }
        upload(name: fileURL.lastPathComponent, mimeType: fileURL.mimeType, data: fileData, completion: completion)
    }
    
}
