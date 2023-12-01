// nft-folder-macos 2023

import Foundation

protocol DownloadableNFT {
    
    var probableDataOrURL: DataOrURL? { get }
    var fileDisplayName: String { get }
    var mimeType: String? { get }
    
    func nftURL(network: Network) -> URL?
    
}
