// ∅ nft-folder 2024

import Cocoa

let dir = FileManager.default.currentDirectoryPath
let selectedPath = dir + "/tools/select/"
let selectedSet = Set(try! FileManager.default.contentsOfDirectory(atPath: selectedPath))

let artblocksUrl = URL(fileURLWithPath: dir + "/tools/artblocks.json")
let artblocksData = try! Data(contentsOf: artblocksUrl)
let artblocks = try! JSONDecoder().decode(Artblocks.self, from: artblocksData)

let bundledSuggestedItemsUrl = URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/items.json")
let currentBundledData = try! Data(contentsOf: bundledSuggestedItemsUrl)
var bundledSuggestedItems = try! JSONDecoder().decode([SuggestedItem].self, from: currentBundledData)
let bundledIds = Set(bundledSuggestedItems.map { $0.id })

let projects = artblocks.data.projects.compactMap {
    $0.curationStatus != .curated ?
    ArtblocksProjectToBundle(name: $0.name,
                             hasVideo: $0.allTokensHaveVideo,
                             tokens: $0.tokens.map { $0.tokenId },
                             contractAddress: $0.contractAddress,
                             projectId: $0.projectId)
    : nil
}

func bundleSelected() {
    for project in projects where !bundledIds.contains(project.id) && selectedSet.contains(project.id) {
        let suggestedItem = SuggestedItem(name: project.name,
                                          address: project.contractAddress,
                                          chainId: 1,
                                          projectId: project.projectId,
                                          hasVideo: project.hasVideo)
        bundledSuggestedItems.append(suggestedItem)
        let bundledTokensItems = project.tokens.map { BundledTokens.Item(id: $0, name: nil, url: nil) }
        let bundledTokens = BundledTokens(isComplete: true, items: bundledTokensItems)
        
        let localImageName = try! FileManager.default.contentsOfDirectory(atPath: selectedPath + project.id).first(where: { !$0.hasPrefix(".") })!
        let coverImageUrl = URL(fileURLWithPath: selectedPath + project.id + "/" + localImageName)
        let rawImageData = try! Data(contentsOf: coverImageUrl)
        let (_, imageData) = NSImage(data: rawImageData)!.resizeToUseAsCoverIfNeeded()!
        
        let imagesetPath = dir + "/Suggested Items/Covers.xcassets/\(project.id).imageset"
        try! FileManager.default.createDirectory(atPath: imagesetPath, withIntermediateDirectories: false)
        let imagesetData = imagesetContentsFileData(id: project.id)
        try! imagesetData.write(to: URL(fileURLWithPath: imagesetPath + "/Contents.json"))
        let fileImageUrl = URL(fileURLWithPath: imagesetPath + "/\(project.id).jpeg")
        try! imageData.write(to: fileImageUrl)
        
        let bundledTokensData = try! JSONEncoder().encode(bundledTokens)
        try! bundledTokensData.write(to: URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/Tokens/\(project.id).json"))
        print("✅ did add \(project.name)")
    }

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let updatedSuggestedItemsData = try! encoder.encode(bundledSuggestedItems)
    try! updatedSuggestedItemsData.write(to: bundledSuggestedItemsUrl)
}

func prepareForSelection() {
    print("will download previews for \(projects.count) projects")

    for project in projects {
        let projectPath = selectedPath + project.id
        try! FileManager.default.createDirectory(atPath: projectPath, withIntermediateDirectories: false)
        for token in project.tokens.prefix(5) {
            let imageURL = URL(string: "https://media-proxy.artblocks.io/\(project.contractAddress)/\(token).png")!
            if let rawImageData = try? Data(contentsOf: imageURL) {
                let fileImageUrl = URL(fileURLWithPath: projectPath + "/\(token).png")
                try! rawImageData.write(to: fileImageUrl)
                print("did add \(token) to \(project.id)")
            }
        }
        print("✅ did add \(project.name)")
    }
}

func removeBundledItems(_ idsString: String) {
    let ids = idsString.split(separator: "\n\n")
    for id in ids {
        bundledSuggestedItems.removeAll(where: { $0.id == id })
        let tokensURL = URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/Tokens/\(id).json")
        try! FileManager.default.removeItem(at: tokensURL)
        let imagesetPath = dir + "/Suggested Items/Covers.xcassets/\(id).imageset"
        try! FileManager.default.removeItem(atPath: imagesetPath)
        print("did remove \(id)")
    }
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let updatedSuggestedItemsData = try! encoder.encode(bundledSuggestedItems)
    try! updatedSuggestedItemsData.write(to: bundledSuggestedItemsUrl)
}

print("🟢 all done")
