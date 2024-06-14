// ∅ nft-folder 2024

import Foundation

let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: UUID().uuidString, qos: .default)
let projectDir = FileManager.default.currentDirectoryPath
let metadataDir = "\(projectDir)/fastlane/metadata/"

translateAppStoreMetadata()

// TODO: do not save with quotes in the first place
// TODO: do not save too long keywords in the first place

func shortenKeywords() {
    for language in Language.allCases where language != .english && language != .russian {
        var text = read(metadataKind: .keywords, language: language)
        
        text = String(text.prefix(100))
        
        write(text, metadataKind: .keywords, language: language)
    }
}

func cleanupQuotes() {
    for metadataKind in MetadataKind.allCases {
        for language in Language.allCases where language != .english && language != .russian {
            var text = read(metadataKind: metadataKind, language: language)
            
            if text.hasSuffix("\"") {
                text = String(text.dropLast())
            }
            
            if text.hasPrefix("\"") {
                text = String(text.dropFirst())
            }
            
            write(text, metadataKind: metadataKind, language: language)
        }
    }
}

func translateAppStoreMetadata() {
    var translationTasksCount = MetadataKind.allCases.filter { $0.toTranslate }.count * (Language.allCases.count - 2)
    for metadataKind in MetadataKind.allCases {
        let englishText = read(metadataKind: metadataKind, language: .english)
        let russianText = read(metadataKind: metadataKind, language: .russian)
        for language in Language.allCases where language != .english {
            let notEmpty = !englishText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if metadataKind.toTranslate && notEmpty {
                guard language != .russian else { continue }
                AI.translate(metadataKind: metadataKind, language: language, englishText: englishText, russianText: russianText) { translation in
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

print("🟢 all done")
