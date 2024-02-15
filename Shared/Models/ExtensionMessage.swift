// ∅ nft-folder-macos 2024

import Foundation

enum ExtensionMessage: Codable {
    
    case didSelectSyncMenuItem
    case didSelectControlCenterMenuItem
    
    case didSelectViewOnMenuItem(path: String, gallery: WebGallery)
    
    case didBeginObservingDirectory(mbAddressName: String?)
    case didEndObservingDirectory(mbAddressName: String?)
    
    case somethingChangedInHomeDirectory
    
}
