// ∅ nft-folder-macos 2024

import Foundation

enum DataOrURL {
    
    case data(Data, String)
    case url(URL)
    
    init?(urlString: String?) {
        guard let urlString = urlString else { return nil }
        if urlString.hasPrefix(URL.ipfsScheme), let url = URL(string: "https://ipfs.decentralized-content.com/ipfs/" + urlString.dropFirst(URL.ipfsScheme.count)) {
            self = .url(url)
        } else if urlString.hasPrefix(URL.arScheme), let url = URL(string: "https://arweave.net/" + urlString.dropFirst(URL.arScheme.count)) {
            self = .url(url)
        } else if !urlString.hasPrefix("http") {
            let components = urlString.components(separatedBy: ",")
            guard components.count == 2, let mimeType = components.first?.split(separator: ";").first?.split(separator: ":").last else { return nil }
            let dataString = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
            
            let decodedData: Data?
            if components.first?.hasSuffix("base64") == true {
                decodedData = Data(base64Encoded: dataString)
            } else {
                let cleanString = dataString.removingPercentEncoding ?? dataString
                decodedData = cleanString.data(using: .utf8)
            }
            
            guard let decodedData = decodedData else { return nil }
            let fileExtension = FileExtension.forMimeType(String(mimeType))
            self = .data(decodedData, fileExtension)
        } else if let url = URL(string: urlString) {
            self = .url(url)
        } else {
            return nil
        }
    }
    
}
