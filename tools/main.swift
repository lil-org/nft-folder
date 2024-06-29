// ∅ nft-folder 2024

import Cocoa

let dir = FileManager.default.currentDirectoryPath

let artblocksUrl = URL(fileURLWithPath: dir + "/tools/artblocks.json")
let artblocksData = try! Data(contentsOf: artblocksUrl)
let artblocks = try! JSONDecoder().decode(Artblocks.self, from: artblocksData)

let bundledSuggestedItemsUrl = URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/items.json")
let currentBundledData = try! Data(contentsOf: bundledSuggestedItemsUrl)
var bundledSuggestedItems = try! JSONDecoder().decode([SuggestedItem].self, from: currentBundledData)
let bundledIds = Set(bundledSuggestedItems.map { $0.id })

let projects = artblocks.data.projects.compactMap {
    $0.curationStatus == .curated ?
    ArtblocksProjectToBundle(name: $0.name,
                             hasVideo: $0.allTokensHaveVideo,
                             tokens: $0.tokens.map { $0.tokenId },
                             contractAddress: $0.contractAddress,
                             projectId: $0.projectId)
    : nil
}

for project in projects where !bundledIds.contains(project.id) {
    let suggestedItem = SuggestedItem(name: project.name,
                                      address: project.contractAddress,
                                      chainId: 1,
                                      projectId: project.projectId,
                                      hasVideo: project.hasVideo)
    bundledSuggestedItems.append(suggestedItem)
    let bundledTokensItems = project.tokens.map { BundledTokens.Item(id: $0, name: nil, url: nil) }
    let bundledTokens = BundledTokens(isComplete: true, items: bundledTokensItems)
    
    let coverTokenId = project.tokens.first!
    let coverImageUrl = URL(string: "https://media.artblocks.io/\(coverTokenId).png")!
    let rawImageData = try! Data(contentsOf: coverImageUrl)
    let (_, imageData) = NSImage(data: rawImageData)!.resizeToUseAsCoverIfNeeded()!
    
    let fileImageUrl = URL(fileURLWithPath: dir + "/tools/\(coverTokenId).jpeg") // TODO: fix path
    try! imageData.write(to: fileImageUrl)
    
    // TODO: write to Tokens/(id).json
    // TODO: write avatar to Covers.xcassets
}

// TODO: write bundledSuggestedItems to items.json
print("🟢 all done")
