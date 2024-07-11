// ∅ nft-folder 2024

import Cocoa

struct ProjectToBundle: Codable {
    
    let name: String
    let tokens: [BundledTokens.Item]
    let contractAddress: String
    let collectionId: String
    let chain: Chain
    
    var id: String {
        return contractAddress + collectionId
    }
    
}

let semaphore = DispatchSemaphore(value: 0)

let dir = FileManager.default.currentDirectoryPath
let wipPath = dir + "/tools/wip/"
let selectedPath = wipPath + "select/"
let selectedSet = Set(try! FileManager.default.contentsOfDirectory(atPath: selectedPath))

let encoder: JSONEncoder = {
    let new = JSONEncoder()
    new.outputFormatting = [.prettyPrinted, .sortedKeys]
    return new
}()

let bundledSuggestedItemsUrl = URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/items.json")
let currentBundledData = try! Data(contentsOf: bundledSuggestedItemsUrl)
var bundledSuggestedItems = try! JSONDecoder().decode([SuggestedItem].self, from: currentBundledData)
let bundledIds = Set(bundledSuggestedItems.map { $0.id })

let projects: [ProjectToBundle] = {
    var result = [ProjectToBundle]()
    
    for path in selectedSet where !path.hasPrefix(".") {
        let data = try! Data(contentsOf: URL(filePath: selectedPath + path + "/" + "project.json"))
        let project = try! JSONDecoder().decode(ProjectToBundle.self, from: data)
        result.append(project)
    }
    
    return result
}()

func bundleSelected(useCollectionImages: Bool) {
    let projectsToBundle = projects.filter { !bundledIds.contains($0.id) && selectedSet.contains($0.id) }
    bundleProjects(projects: projectsToBundle, useCollectionImages: useCollectionImages)
    semaphore.wait()
    let updatedSuggestedItemsData = try! encoder.encode(bundledSuggestedItems)
    try! updatedSuggestedItemsData.write(to: bundledSuggestedItemsUrl)
}

fileprivate func bundleProjects(projects: [ProjectToBundle], useCollectionImages: Bool) {
    if let project = projects.first {
        let suggestedItem = SuggestedItem(name: project.name,
                                          address: project.contractAddress,
                                          chainId: project.chain.network.rawValue,
                                          chain: project.chain,
                                          collectionId: project.collectionId,
                                          abId: nil,
                                          hasVideo: nil)
        bundledSuggestedItems.append(suggestedItem)
        
        SimpleHash.getAllNfts(collectionId: project.collectionId, next: nil, addTo: []) { nfts in
            let tokens = nfts.map { $0.toBundle }
            let bundledTokens = BundledTokens(isComplete: true, items: tokens)
            
            if useCollectionImages {
                rebundleImages(items: [suggestedItem], useCollectionImage: true, doNotSignal: true)
            } else {
                let localImageName = try! FileManager.default.contentsOfDirectory(atPath: selectedPath + project.id).first(where: { !$0.hasPrefix(".") })!
                let coverImageUrl = URL(fileURLWithPath: selectedPath + project.id + "/" + localImageName)
                let rawImageData = try! Data(contentsOf: coverImageUrl)
                
                let coverImage: NSImage
                if let image = NSImage(data: rawImageData) {
                    coverImage = image
                } else {
                    let anotherData = try! Data(contentsOf: URL(string: nfts.randomElement()!.previews!.imageMediumUrl!)!)
                    coverImage = NSImage(data: anotherData)!
                }
                
                writeImage(coverImage, id: project.id)
            }
            
            let bundledTokensData = try! JSONEncoder().encode(bundledTokens)
            let jsonString = String(data: bundledTokensData, encoding: .utf8)!
            try! jsonString.write(to: URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/Tokens/\(project.id).json"), atomically: true, encoding: .utf8)
            print("✅ did add \(project.name)")
            
            bundleProjects(projects: Array(projects.dropFirst()), useCollectionImages: useCollectionImages)
        }
        
    } else {
        semaphore.signal()
    }
}

func writeImage(_ image: NSImage, id: String) {
    let (_, imageData) = image.resizeToUseAsCoverIfNeeded()!
    let imagesetPath = dir + "/Suggested Items/Covers.xcassets/\(id).imageset"
    
    if FileManager.default.fileExists(atPath: imagesetPath) {
        try! FileManager.default.removeItem(atPath: imagesetPath)
    }
    
    try! FileManager.default.createDirectory(atPath: imagesetPath, withIntermediateDirectories: false)
    let imagesetData = imagesetContentsFileData(id: id)
    try! imagesetData.write(to: URL(fileURLWithPath: imagesetPath + "/Contents.json"))
    let fileImageUrl = URL(fileURLWithPath: imagesetPath + "/\(id).jpeg")
    try! imageData.write(to: fileImageUrl)
}

func hasImage(id: String) -> Bool {
    let imagesetPath = dir + "/Suggested Items/Covers.xcassets/\(id).imageset"
    let hasDir = FileManager.default.fileExists(atPath: imagesetPath)
    let hasImage = FileManager.default.fileExists(atPath: imagesetPath + "/\(id).jpeg")
    return hasDir && hasImage
}

func prepareForSelection(_ input: String) {
    let fresh: [(String, Chain)] = input.split(separator: "\n\n").map { (String($0), .ethereum) }
    SimpleHash.previewCollections(fresh)
    print("will download previews for \(projects.count) projects")
    processProjects(projects: projects)
    semaphore.wait()
}

fileprivate func processProjects(projects: [ProjectToBundle]) {
    if let project = projects.first {
        let projectPath = selectedPath + project.id
        guard try! FileManager.default.contentsOfDirectory(atPath: projectPath).count < 5 else {
            processProjects(projects: Array(projects.dropFirst()))
            return
        }
        
        SimpleHash.previewNfts(collectionId: project.collectionId) { nfts in
            for token in nfts.prefix(5) {
                guard let imageUrlString = token.imageUrl else { continue }
                let imageURL = URL(string: imageUrlString)!
                if let rawImageData = try? Data(contentsOf: imageURL) {
                    let fileName = "\(token.name ?? "untitled")-\(token.tokenId).\(imageURL.pathExtension)".replacingOccurrences(of: "/", with: "")
                    let fileImageUrl = URL(fileURLWithPath: projectPath + "/" + fileName)
                    try! rawImageData.write(to: fileImageUrl)
                    print("did add \(fileName) to \(project.name)")
                }
            }
            print("✅ did add \(project.name)")
            processProjects(projects: Array(projects.dropFirst()))
        }
    } else {
        semaphore.signal()
    }
}

func removeBundledItems(batchIds: String) {
    let ids = batchIds.split(separator: "\n\n")
    for id in ids {
        removeBundledItem(id: String(id))
    }
    saveSuggestedItemsJson()
}

func removeBundledItem(name: String) {
    guard !name.isEmpty else { return }
    let idsToRemove = bundledSuggestedItems.filter { $0.name.localizedCaseInsensitiveContains(name) }.map { $0.id }
    guard idsToRemove.count < 4 else {
        print("hmm won't remove \(idsToRemove.count) items automatically")
        return
    }
    for id in idsToRemove {
        removeBundledItem(id: id)
    }
    saveSuggestedItemsJson()
}

fileprivate func removeBundledItem(id: String) {
    bundledSuggestedItems.removeAll(where: { $0.id == id })
    let tokensURL = URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/Tokens/\(id).json")
    try! FileManager.default.removeItem(at: tokensURL)
    let imagesetPath = dir + "/Suggested Items/Covers.xcassets/\(id).imageset"
    try! FileManager.default.removeItem(atPath: imagesetPath)
    print("did remove \(id)")
}

fileprivate func saveSuggestedItemsJson() {
    let updatedSuggestedItemsData = try! encoder.encode(bundledSuggestedItems)
    try! updatedSuggestedItemsData.write(to: bundledSuggestedItemsUrl)
}

fileprivate func imagesetContentsFileData(id: String) -> Data {
    let jsonString =
    """
    {
      "images" : [
        {
          "filename" : "\(id).jpeg",
          "idiom" : "universal"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    return jsonString.data(using: .utf8)!
}

func rebundleImages(onlyMissing: Bool, useCollectionImage: Bool) {
    if onlyMissing {
        var missing = [SuggestedItem]()
        for item in bundledSuggestedItems {
            if !hasImage(id: item.id) {
                missing.append(item)
                print("no image for \(item.name)")
            }
        }
        rebundleImages(items: missing, useCollectionImage: useCollectionImage, doNotSignal: false)
    } else {
        print("will rebundle all images")
        rebundleImages(items: bundledSuggestedItems, useCollectionImage: useCollectionImage, doNotSignal: false)
    }
    semaphore.wait()
}

private func rebundleImages(items: [SuggestedItem], useCollectionImage: Bool, doNotSignal: Bool) {
    if let item = items.first {
        if item.abId != nil {
            let data = try! Data(contentsOf: URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/Tokens/\(item.id).json"))
            let tokens = try! JSONDecoder().decode(BundledTokens.self, from: data)
            let tokenId = tokens.items.randomElement()!.id
            if useCollectionImage {
                print("⚠️ will not get an image for artblocks \(item.name)")
            } else {
                let url = URL(string: "https://media-proxy.artblocks.io/\(item.address)/\(tokenId).png")
                let imageData = try! Data(contentsOf: url!)
                let coverImage = NSImage(data: imageData)!
                writeImage(coverImage, id: item.id)
                print("did update image for \(item.name)")
                rebundleImages(items: Array(items.dropFirst()), useCollectionImage: useCollectionImage, doNotSignal: doNotSignal)
            }
        } else if let collectionId = item.collectionId {
            SimpleHash.getNfts(collectionId: collectionId, next: nil, count: 23) { result in
                let nft = result.nfts.randomElement()!
                let url: URL
                if useCollectionImage, let collectionImageUrlString = nft.collection?.imageUrl {
                    url = URL(string: collectionImageUrlString)!
                } else {
                    url = URL(string: nft.previews!.imageMediumUrl!)!
                }
                let data = try! Data(contentsOf: url)
                let coverImage = NSImage(data: data)!
                writeImage(coverImage, id: item.id)
                print("did update image for \(item.name)")
                rebundleImages(items: Array(items.dropFirst()), useCollectionImage: useCollectionImage, doNotSignal: doNotSignal)
            }
        } else {
            print("⚠️ will not get an image for \(item.name)")
            rebundleImages(items: Array(items.dropFirst()), useCollectionImage: useCollectionImage, doNotSignal: doNotSignal)
        }
    } else if !doNotSignal {
        semaphore.signal()
    }
}
