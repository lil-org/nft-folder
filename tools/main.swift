// ∅ nft-folder 2024

import Foundation

let dir = FileManager.default.currentDirectoryPath
let url = URL(fileURLWithPath: dir + "/tools/artblocks.json")
let data = try! Data(contentsOf: url)
let artblocks = try! JSONDecoder().decode(Artblocks.self, from: data)
let projects = artblocks.data.projects.compactMap {
    $0.curationStatus == .curated ?
    ArtblocksProjectToBundle(hasVideo: $0.allTokensHaveVideo,
                             tokens: $0.tokens.map { $0.tokenId },
                             contractAddress: $0.contractAddress,
                             projectId: $0.projectId)
    : nil
}

print(projects.count)
