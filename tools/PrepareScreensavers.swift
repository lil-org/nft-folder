// ∅ nft-folder 2024

import Foundation

func setupForScreenSaverBuild(_ number: Int) {
    // TODO: implement
    let jsonNames = try! FileManager.default.contentsOfDirectory(atPath: dir + "/Suggested Items/Suggested.bundle/Generative/")
    var items = [SuggestedItem]()
    for jsonName in jsonNames {
        let data = try! Data(contentsOf: URL(filePath: dir + "/Suggested Items/Suggested.bundle/Generative/" + jsonName))
        let generativeProject = try! JSONDecoder().decode(GenerativeProject.self, from: data)
        let item = bundledSuggestedItems.first(where: { $0.id == generativeProject.id })!
        items.append(item)
        print(item.name)
    }
}
