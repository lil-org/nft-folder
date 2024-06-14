// ∅ nft-folder 2024

import Foundation

struct AI {
    
    enum Model {
        case cheap, highQuality
        
        var name: String {
            switch self {
            case .cheap:
                return "gpt-3.5-turbo"
            case .highQuality:
                return "gpt-4"
            }
        }
    }
    
    private static let apiKey: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let url = home.appending(path: "Developer/secrets/tools/OPENAI_API_KEY")
        let data = try! Data(contentsOf: url)
        return String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
    }()
    
    static func translate(_ model: Model, metadataKind: MetadataKind, language: Language, englishText: String, russianText: String, completion: @escaping (String) -> Void) {
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
        sendRequest(model: model, prompt: prompt) { response in
            completion(response!)
        }
        
        // TODO: check if there were changes since the last translation run
        // TODO: call completion with a current version if there is no need to translate again
        // A description of your app, detailing features and functionality.
        // Separate keywords with an English comma, Chinese comma, or a mix of both.
        // max 100 chars for keywords
        // Describe what's new in this version of your app, such as new features, improvements, and bug fixes.
    }
    
    private static func sendRequest(model: Model, prompt: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "model": model.name,
            "messages": [["role": "user", "content": prompt]]
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String {
                completion(content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "\""))))
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
}
