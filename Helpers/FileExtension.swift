// ∅ 2025 lil org

import Foundation
import UniformTypeIdentifiers

struct FileExtension {
    
    private init() {}
    
    static func forMimeType(_ mimeType: String) -> String {
        if let preferred = UTType(mimeType: mimeType)?.preferredFilenameExtension {
            return preferred
        } else if mimeType == "model/gltf-binary" {
            return "glb"
        } else if mimeType == "model/gltf+json" {
            return "gltf"
        } else {
            return FileExtension.placeholder
        }
    }
    
    static let placeholder = "gif"
    
}
