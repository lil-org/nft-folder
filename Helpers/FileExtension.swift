// nft-folder-macos 2024

import Foundation
import UniformTypeIdentifiers

struct FileExtension {
    
    private init() {}
    
    static func forMimeType(_ mimeType: String) -> String {
        if let utType = UTType(mimeType: mimeType) {
            return utType.preferredFilenameExtension ?? FileExtension.placeholder
        } else {
            return FileExtension.placeholder
        }
    }
    
    static let placeholder = "gif"
    
}
