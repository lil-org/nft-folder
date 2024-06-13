// ∅ nft-folder 2024

import Foundation

let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: UUID().uuidString, qos: .default)
let projectDir = FileManager.default.currentDirectoryPath
let metadataDir = "\(projectDir)/fastlane/metadata/"

translateAppStoreMetadata()

func translateAppStoreMetadata() {
    var translationTasksCount = MetadataKind.allCases.filter { $0.toTranslate }.count * (Language.allCases.count - 2)
    for metadataKind in MetadataKind.allCases {
        let englishText = read(metadataKind: metadataKind, language: .english)
        let russianText = read(metadataKind: metadataKind, language: .russian)
        for language in Language.allCases where language != .english {
            if metadataKind.toTranslate {
                guard language != .russian else { continue }
                translate(metadataKind: metadataKind, englishText: englishText, russianText: russianText) { translation in
                    write(translation, metadataKind: metadataKind, language: language)
                    translationTasksCount -= 1
                    if translationTasksCount == 0 {
                        semaphore.signal()
                    }
                }
            } else {
                write(englishText, metadataKind: metadataKind, language: language)
            }
        }
    }
    semaphore.wait()
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

func translate(metadataKind: MetadataKind, englishText: String, russianText: String, completion: @escaping (String) -> Void) {
    completion(englishText)
    // TODO: check if there were changes since the last translation run
    // TODO: complete with a current version if there is no need to translate again
    // TODO: implement translation using ru and eng
    // A description of your app, detailing features and functionality.
    // Separate keywords with an English comma, Chinese comma, or a mix of both.
    // max 100 chars for keywords
    // Describe what's new in this version of your app, such as new features, improvements, and bug fixes.
}

print("🟢 all done")
