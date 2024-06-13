// ∅ nft-folder 2024

import Foundation

let projectDir = FileManager.default.currentDirectoryPath
let metadataDir = "\(projectDir)/fastlane/metadata/"

translateAppStoreMetadata()

func translateAppStoreMetadata() {
    for metadataKind in MetadataKind.allCases {
        let englishValue = read(metadataKind: metadataKind, language: .english)
        let russianValue = read(metadataKind: metadataKind, language: .russian)
        for language in Language.allCases where language != .english {
            if metadataKind.toTranslate {
                guard language != .russian else { continue }
                // TODO: check if there were changes since the last translation run
                // TODO: implement translation using ru and eng
                // A description of your app, detailing features and functionality.
                // Separate keywords with an English comma, Chinese comma, or a mix of both.
                // max 100 chars for keywords
                // Describe what's new in this version of your app, such as new features, improvements, and bug fixes.
                let translation = englishValue
                write(translation, metadataKind: metadataKind, language: language)
            } else {
                write(englishValue, metadataKind: metadataKind, language: language)
            }
        }
    }
}

func read(metadataKind: MetadataKind, language: Language) -> String {
    let url = url(metadataKind: metadataKind, language: language)
    let data = try! Data(contentsOf: url)
    let text = String(data: data, encoding: .utf8)!
    return text
}

func write(_ newValue: String, metadataKind: MetadataKind, language: Language) {
    let url = url(metadataKind: metadataKind, language: language)
    let data = newValue.data(using: .utf8)!
    try! data.write(to: url)
}

func url(metadataKind: MetadataKind, language: Language) -> URL {
    return URL(fileURLWithPath: metadataDir + "\(language.metadataLocalizationKey)/\(metadataKind.fileName).txt")
}
