// ∅ nft-folder-macos 2024

import Foundation
import UniformTypeIdentifiers

struct ContentRepresentation: Codable {
    
    enum Kind: String, Codable {
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
            if mimeType == "model/gltf-binary" || mimeType == "model/gltf+json" {
                self.kind = .glb
            } else if let utType = UTType(mimeType: mimeType) {
                if utType.conforms(to: .image) {
                    self.kind = .image
                } else if utType.conforms(to: .audio) {
                    self.kind = .audio
                } else if utType.conforms(to: .movie) {
                    self.kind = .video
                } else if utType.conforms(to: .html) {
                    self.kind = .html
                } else {
                    self.kind = .other
                }
            } else {
                self.kind = .other
            }
        } else {
            self.kind = nil
        }
    }
    
}
