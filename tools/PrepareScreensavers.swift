// ∅ nft-folder 2024

import Cocoa

func setupForScreenSaverBuild(_ number: Int) {
    let jsonNames = try! FileManager.default.contentsOfDirectory(atPath: dir + "/Suggested Items/Suggested.bundle/Generative/").sorted()
    
    let jsonName = jsonNames[number]
    let data = try! Data(contentsOf: URL(filePath: dir + "/Suggested Items/Suggested.bundle/Generative/" + jsonName))
    let generativeProject = try! JSONDecoder().decode(GenerativeProject.self, from: data)
    let item = bundledSuggestedItems.first(where: { $0.id == generativeProject.id })!
    
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(item.name, forType: .string)
    
    let lib = ScriptType(rawValue: generativeProject.kind.rawValue)?.libScript
    let script = generativeProject.script
    let imageData = try! Data(contentsOf: URL(filePath: wipPath + "/previews/\(item.id)"))
    
    // TODO: put script in there
    // TODO: put library in there
    // TODO: put thumbnail image in there
}
