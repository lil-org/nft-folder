// ∅ nft-folder 2024

import Foundation

let projectDir = FileManager.default.currentDirectoryPath
let metadataDir = "\(projectDir)/fastlane/metadata/"

translateAppStoreMetadata()

func translateAppStoreMetadata() {
    for targetLanguage in Language.targets {
        let url = URL(fileURLWithPath: metadataDir + "\(targetLanguage.metadataLocalizationKey)/description.txt")
        let data = try! Data(contentsOf: url)
        let description = String(data: data, encoding: .utf8)!
        let newData = description.data(using: .utf8)
        try! data.write(to: url)
    }
    
    // TODO: go trough all locales
    // TODO: use en and ru versions as a reference
    // TODO: check if there were changes since the last translation run
    
    // A description of your app, detailing features and functionality.
    // Separate keywords with an English comma, Chinese comma, or a mix of both.
    // max 100 chars for keywords
    // Describe what's new in this version of your app, such as new features, improvements, and bug fixes.
}
