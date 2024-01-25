// ∅ nft-folder-macos 2024

import Foundation

protocol DownloadableNFT {
    
    var probableDataOrURL: DataOrURL? { get }
    var fileDisplayName: String { get }
    var tokenId: String { get }
    var collectionAddress: String { get }
    
}
