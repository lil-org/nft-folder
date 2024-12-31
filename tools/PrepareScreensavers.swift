// ∅ 2025 lil org

import Cocoa

func setupForScreenSaverBuild(_ number: Int) {
    let jsonNames = try! FileManager.default.contentsOfDirectory(atPath: dir + "/Suggested Items/Suggested.bundle/Scripts/").sorted()
    
    let jsonName = jsonNames[number]
    let id = String(jsonName.dropLast(5))
    let data = try! Data(contentsOf: URL(filePath: dir + "/Suggested Items/Suggested.bundle/Scripts/" + jsonName))
    let script = try! JSONDecoder().decode(Script.self, from: data)
    
    if script.screensaverFileName != nil {
        setupForScreenSaverBuild(number + 1)
        return
    }
    
    let item = bundledSuggestedItems.first(where: { $0.id == id })!
    
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(item.name, forType: .string)
    
    let lib = ScriptType(rawValue: script.kind.rawValue)!.libScript
    let projectJsonString = String(data: data, encoding: .utf8)!
    let imageData = try! Data(contentsOf: URL(filePath: toolsPath + "previews/\(item.id).heic"))
    
    let targetImagePath = dir + "/nft-screen-saver/NftScreenSaverView/thumbnail.heic"
    try! FileManager.default.removeItem(atPath: targetImagePath)
    try! imageData.write(to: URL(filePath: targetImagePath))
    
    let tripleQuotes = "\"\"\""
    
    let projectFileContents =
    """
    import Foundation

    let projectJsonString =
    #\(tripleQuotes)
    \(projectJsonString)
    \(tripleQuotes)#
    """

    try! projectFileContents.write(toFile: dir + "/nft-screen-saver/ProjectJsonString.swift", atomically: true, encoding: .utf8)
    
    let libFileContents =
    """
    import Foundation

    let libScript =
    #\(tripleQuotes)
    \(encodeToBase64(lib))
    \(tripleQuotes)#
    """

    try! libFileContents.write(toFile: dir + "/nft-screen-saver/LibScriptString.swift", atomically: true, encoding: .utf8)
    print(item.name)
    print("NEXT NUMBER: \(number + 1)")
}

func encodeToBase64(_ input: String) -> String {
    let data = input.data(using: .utf8)!
    return data.base64EncodedString()
}
