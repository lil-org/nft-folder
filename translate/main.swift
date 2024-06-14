// ∅ nft-folder 2024

import Foundation

let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: UUID().uuidString, qos: .default)
let projectDir = FileManager.default.currentDirectoryPath

translateAppStoreMetadata(.cheap)

// TODO: do not save too long keywords in the first place

func shortenKeywords() {
    for language in Language.allCases where language != .english && language != .russian {
        var text = read(metadataKind: .keywords, language: language)
        
        text = String(text.prefix(100))
        
        write(text, metadataKind: .keywords, language: language)
    }
}

func translateAppStoreMetadata(_ model: AI.Model) {
    var translationTasksCount = MetadataKind.allCases.filter { $0.toTranslate }.count * (Language.allCases.count - 2)
    for metadataKind in MetadataKind.allCases {
        let englishText = originalMetadata(kind: metadataKind, language: .english)
        let russianText = originalMetadata(kind: metadataKind, language: .russian)
        write(englishText, metadataKind: metadataKind, language: .english)
        write(russianText, metadataKind: metadataKind, language: .russian)
        let notEmpty = !englishText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        for language in Language.allCases where language != .english && language != .russian {
            if metadataKind.toTranslate && notEmpty {
                AI.translate(model, metadataKind: metadataKind, language: language, englishText: englishText, russianText: russianText) { translation in
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
    return read(url: url)
}

func read(url: URL) -> String {
    let data = try! Data(contentsOf: url)
    let text = String(data: data, encoding: .utf8)!
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
}

func write(_ newValue: String, metadataKind: MetadataKind, language: Language) {
    let textToWrite: String = {
        if metadataKind == .keywords && newValue.count > 100 {
            print("🟡 trimming \(language.name) keywords")
            return String(newValue.prefix(100))
        } else {
            return newValue
        }
    }()
    let url = url(metadataKind: metadataKind, language: language)
    let data = textToWrite.data(using: .utf8)!
    try! data.write(to: url)
}

func originalMetadata(kind: MetadataKind, language: Language) -> String {
    let suffix = kind.toTranslate && language == .russian ? "_ru" : ""
    let url = URL(fileURLWithPath: projectDir + "/app-store/" + "\(kind.fileName)\(suffix).txt")
    return read(url: url)
}

func url(metadataKind: MetadataKind, language: Language) -> URL {
    return URL(fileURLWithPath: projectDir + "/fastlane/metadata/" + "\(language.metadataLocalizationKey)/\(metadataKind.fileName).txt")
}

print("🟢 all done")
