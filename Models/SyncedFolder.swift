// ∅ nft-folder 2024

import Foundation

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
