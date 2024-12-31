// ∅ 2025 lil org

import Foundation

func translateAppStoreMetadata(_ model: AI.Model) {
    var tasks = [MetadataTask]()
    
    for platform in Platform.allCases {
        for metadataKind in MetadataKind.allCases {
            if metadataKind.isCommonForAllPlatforms && platform != .common || !metadataKind.isCommonForAllPlatforms && platform == .common { continue }
            
            let englishText = originalMetadata(kind: metadataKind, platform: platform, language: .english)
            let russianText = originalMetadata(kind: metadataKind, platform: platform, language: .russian)
            write(englishText, englishOriginal: englishText, metadataKind: metadataKind, platform: platform, language: .english)
            write(russianText, englishOriginal: englishText, metadataKind: metadataKind, platform: platform, language: .russian)
            let notEmpty = !englishText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            for language in Language.allCases where language != .english && language != .russian {
                if metadataKind.toTranslate && notEmpty {
                    let task = MetadataTask(model: model, metadataKind: metadataKind, platform: platform, language: language, englishText: englishText, russianText: russianText)
                    if !task.wasCompletedBefore {
                        tasks.append(task)
                    }
                } else {
                    write(englishText, englishOriginal: englishText, metadataKind: metadataKind, platform: platform, language: language)
                }
            }
        }
    }
    
    var finalTasksCount = tasks.count
    for task in tasks {
        AI.translate(task: task) { translation in
            write(translation, englishOriginal: task.englishText, metadataKind: task.metadataKind, platform: task.platform, language: task.language)
            task.storeAsCompleted()
            finalTasksCount -= 1
            if finalTasksCount == 0 {
                semaphore.signal()
            }
        }
    }
    
    if !tasks.isEmpty {
        semaphore.wait()
    }
}

func write(_ newValue: String, englishOriginal: String, metadataKind: MetadataKind, platform: Platform, language: Language) {
    let toWrite: String
    if metadataKind == .subtitle && newValue.count > 30 {
        toWrite = englishOriginal
    } else if metadataKind == .keywords && newValue.count > 100 {
        toWrite = englishOriginal
    } else {
        toWrite = newValue
    }
    
    let actualPlatformsToWrite: [Platform] = platform == .common ? [.macos, .tvos, .visionos] : [platform]
    for p in actualPlatformsToWrite {
        let url = URL(fileURLWithPath: projectDir + "/fastlane/metadata/\(p.rawValue)/" + "\(language.metadataLocalizationKey)/\(metadataKind.fileName).txt")
        let data = toWrite.data(using: .utf8)!
        try! data.write(to: url)
    }
}

func originalMetadata(kind: MetadataKind, platform: Platform, language: Language) -> String {
    let suffix = kind.toTranslate && language == .russian ? "_ru" : ""
    let url = URL(fileURLWithPath: projectDir + "/app_store/\(platform.rawValue)/" + "\(kind.fileName)\(suffix).txt")
    let data = try! Data(contentsOf: url)
    let text = String(data: data, encoding: .utf8)!
    return text.trimmingCharacters(in: .whitespacesAndNewlines)
}
