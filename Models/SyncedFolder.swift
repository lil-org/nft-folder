// ∅ nft-folder 2024

import Foundation

struct FolderSnapshot: Codable {
    
    static let latestFormatVersion = 0
    
    let formatVersion: Int
    let uuid: String
    let nonce: Int
    let address: String
    let rootFolder: SyncedFolder
    
}

struct SyncedFolder: Codable {
    
    let name: String
    let nfts: [NftInSyncedFolder]
    let childrenFolders: [SyncedFolder]
    
}

struct NftInSyncedFolder: Codable {

    let chainId: String
    let tokenId: String
    let address: String
    
}
