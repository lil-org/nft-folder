// ∅ nft-folder-macos 2024

import Foundation

protocol DownloadableNFT {
    
    var probableDataOrURLs: [DataOrURL] { get }
    var fileDisplayName: String { get }
    var tokenId: String { get }
    var collectionAddress: String { get }
    
}
