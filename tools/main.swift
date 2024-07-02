// ∅ nft-folder 2024

import Cocoa

let semaphore = DispatchSemaphore(value: 0)

let dir = FileManager.default.currentDirectoryPath
let selectedPath = dir + "/tools/wip/select/"
let selectedSet = Set(try! FileManager.default.contentsOfDirectory(atPath: selectedPath))

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

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

func bundleSelected() {
    let projectsToBundle = projects.filter { !bundledIds.contains($0.id) && selectedSet.contains($0.id) }
    bundleProjects(projects: projectsToBundle)
    semaphore.wait()
    let updatedSuggestedItemsData = try! encoder.encode(bundledSuggestedItems)
    try! updatedSuggestedItemsData.write(to: bundledSuggestedItemsUrl)
}

func bundleProjects(projects: [ProjectToBundle]) {
    if let project = projects.first {
        let suggestedItem = SuggestedItem(name: project.name,
                                          address: project.contractAddress,
                                          chainId: 1,
                                          projectId: project.projectId,
                                          hasVideo: false)
        bundledSuggestedItems.append(suggestedItem)
        
        SimpleHash.getAllNfts(collectionId: project.projectId, next: nil, addTo: []) { nfts in
            let tokens = nfts.map { $0.toBundle }
            let bundledTokens = BundledTokens(isComplete: true, items: tokens)
            
            let localImageName = try! FileManager.default.contentsOfDirectory(atPath: selectedPath + project.id).first(where: { !$0.hasPrefix(".") })!
            let coverImageUrl = URL(fileURLWithPath: selectedPath + project.id + "/" + localImageName)
            let rawImageData = try! Data(contentsOf: coverImageUrl)
            
            if let image = NSImage(data: rawImageData), let (_, imageData) = image.resizeToUseAsCoverIfNeeded() {
                let imagesetPath = dir + "/Suggested Items/Covers.xcassets/\(project.id).imageset"
                try! FileManager.default.createDirectory(atPath: imagesetPath, withIntermediateDirectories: false)
                let imagesetData = imagesetContentsFileData(id: project.id)
                try! imagesetData.write(to: URL(fileURLWithPath: imagesetPath + "/Contents.json"))
                let fileImageUrl = URL(fileURLWithPath: imagesetPath + "/\(project.id).jpeg")
                try! imageData.write(to: fileImageUrl)
            } else {
                // TODO: get another image from simplehash
                print("⚠️ did not set an image for \(project.name) \(project.id)")
            }
            
            let bundledTokensData = try! JSONEncoder().encode(bundledTokens)
            let jsonString = String(data: bundledTokensData, encoding: .utf8)!
            try! jsonString.write(to: URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/Tokens/\(project.id).json"), atomically: true, encoding: .utf8)
            print("✅ did add \(project.name)")
            
            bundleProjects(projects: Array(projects.dropFirst()))
        }
        
    } else {
        semaphore.signal()
    }
}

func prepareForSelection(input: String) {
    SimpleHash.previewCollections(input: input)
    print("will download previews for \(projects.count) projects")
    processProjects(projects: projects)
    semaphore.wait()
}

func processProjects(projects: [ProjectToBundle]) {
    if let project = projects.first {
        let projectPath = selectedPath + project.id
        guard try! FileManager.default.contentsOfDirectory(atPath: projectPath).count < 5 else {
            processProjects(projects: Array(projects.dropFirst()))
            return
        }
        
        SimpleHash.previewNfts(collectionId: project.projectId) { nfts in
            for token in nfts.prefix(5) {
                guard let imageUrlString = token.imageUrl else { continue }
                let imageURL = URL(string: imageUrlString)!
                if let rawImageData = try? Data(contentsOf: imageURL) {
                    let fileName = "\(token.name)-\(token.tokenId).\(imageURL.pathExtension)".replacingOccurrences(of: "/", with: "")
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
    let updatedSuggestedItemsData = try! encoder.encode(bundledSuggestedItems)
    try! updatedSuggestedItemsData.write(to: bundledSuggestedItemsUrl)
}

bundleSelected()

print("🟢 all done")
