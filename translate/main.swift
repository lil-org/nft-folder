// ∅ nft-folder 2024

import Foundation

let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: UUID().uuidString, qos: .default)
let projectDir = FileManager.default.currentDirectoryPath
let metadataDir = "\(projectDir)/fastlane/metadata/"

 translateAppStoreMetadata()

// TODO: do not save qith quotes in the first place

func cleanup() {
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
                translate(metadataKind: metadataKind, language: language, englishText: englishText, russianText: russianText) { translation in
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

func translate(metadataKind: MetadataKind, language: Language, englishText: String, russianText: String, completion: @escaping (String) -> Void) {
    let metadataName = "text" // TODO: vary based on metadataKind
    let prompt = """
        translate the \(metadataName) to \(language.name).
    
        feel free to tune it to make \(language.name) version sound natural.
    
        make sure the translated version communicates the same message.
    
        keep it simple and straightforward.
    
        use english and russian texts below as a reference.
    
        english:
        "\(englishText)"
    
        russian:
        "\(russianText)"
    
        respond only with a \(language.name) version. do not add anything else to the response.
    """
    sendRequest(prompt: prompt) { response in
        completion(response!)
    }
    
    // TODO: check if there were changes since the last translation run
    // TODO: call completion with a current version if there is no need to translate again
    // A description of your app, detailing features and functionality.
    // Separate keywords with an English comma, Chinese comma, or a mix of both.
    // max 100 chars for keywords
    // Describe what's new in this version of your app, such as new features, improvements, and bug fixes.
}

func sendRequest(prompt: String, completion: @escaping (String?) -> Void) {
    let apiKey = "" // TODO: set from env
    let url = URL(string: "https://api.openai.com/v1/chat/completions")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let requestBody: [String: Any] = [
        "model": "gpt-4o",
        "messages": [
            ["role": "user", "content": prompt]
        ]
    ]
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
    } catch {
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completion(nil)
            return
        }
        
        guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            completion(nil)
            return
        }
        
        print("yo")
        
        if let hmm = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print(hmm)
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                print(json)
                completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                completion(nil)
            }
        } catch {
            completion(nil)
        }
        
    }
    task.resume()
}


print("🟢 all done")
