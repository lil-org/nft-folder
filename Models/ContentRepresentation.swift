// ∅ nft-folder-macos 2024

import Foundation

struct ContentRepresentation: Codable {
    
    enum Kind: Codable {
        case image, audio, video, html, glb, other
    }
    
    let dataOrUrl: DataOrUrl
    let size: Int?
    let kind: Kind?
    
    init?(url: String?, size: String?, mimeType: String?, knownKind: Kind?) {
        guard let dataOrUrl = DataOrUrl(urlString: url) else { return nil }
        self.dataOrUrl = dataOrUrl
        
        if let size = size {
            self.size = Int(size)
        } else {
            self.size = nil
        }
        
        if let knownKind = knownKind {
            self.kind = knownKind
        } else if let mimeType = mimeType {
            self.kind = .other // TODO: implement
        } else {
            self.kind = nil
        }
    }
    
}
