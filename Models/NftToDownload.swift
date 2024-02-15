// ∅ nft-folder-macos 2024

import Foundation

protocol NftToDownload {
    
    var probableDataOrUrls: [DataOrUrl] { get }
    var fileDisplayName: String { get }
    var tokenId: String { get }
    var collectionAddress: String { get }
    
}
