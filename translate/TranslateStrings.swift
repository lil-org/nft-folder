// ∅ nft-folder 2024

import Foundation

func translateAllString() {
    let strings = readStrings()
    var newStrings = [String: Any]()
    for key in strings.keys {
        let localizations = (strings[key] as! [String: Any])["localizations"] as! [String: Any]
        processSpecificString(key: key, localizations: localizations) { result in
            newStrings[key] = ["localizations": result]
            if newStrings.count == strings.count {
                writeStrings(newStrings)
                print("✅ did write new strings")
                semaphore.signal()
            }
        }
    }
    semaphore.wait()
}

func processSpecificString(key: String, localizations: [String: Any], completion: @escaping ([String: Any]) -> Void) {
    let english = read(language: .english, from: localizations)
    let russian = read(language: .russian, from: localizations)
    
    var dict: [Language: String] = [
        .english: english,
        .russian: russian
    ]
    
    for language in Language.allCases where language != .english && language != .russian {
        translate(to: language, english: english, russian: russian) { result in
            dict[language] = result
            if dict.count == Language.allCases.count {
                let formatted = formatLocalizationsDict(dict)
                completion(formatted)
            }
        }
    }
}

func translate(to: Language, english: String, russian: String, completion: @escaping (String) -> Void) {
    queue.asyncAfter(deadline: .now() + .seconds(1)) {
        // TODO: implement translation
    }
}

func formatLocalizationsDict(_ input: [Language: String]) -> [String: Any] {
    var output = [String: Any]()
    
    for (key, value) in input {
        output[key.appLocalizationKey] = ["stringUnit": ["state" : "translated", "value": value]]
    }
    
    return output
}

func read(language: Language, from localizations: [String: Any]) -> String {
    let unit = (localizations[language.appLocalizationKey] as! [String: Any])["stringUnit"] as! [String: String]
    let value = unit["value"]!
    return value
}

func writeStrings(_ newStrings: [String: Any]) {
    let newDict: [String: Any] = ["sourceLanguage": "en", "strings": newStrings, "version" : "1.0"]
    let data = try! JSONSerialization.data(withJSONObject: newDict, options: [.prettyPrinted, .sortedKeys])
    try! data.write(to: stringsURL)
}

func readStrings() -> [String: Any] {
    let data = try! Data(contentsOf: stringsURL)
    let json = try! JSONSerialization.jsonObject(with: data) as! [String: Any]
    let strings = json["strings"] as! [String: Any]
    return strings
}

func addNewString(key: String, english: String, russian: String) {
    // TODO: do nothing if it already exists
    // TODO: add everywhere and translate
}

private let stringsURL = URL(fileURLWithPath: projectDir + "/nft-folder/Localizable.xcstrings")
