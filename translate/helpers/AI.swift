// ∅ 2025 lil org

import Foundation

struct AI {
    
    protocol Task {
        var model: Model { get }
        var prompt: String { get }
        var description: String { get }
    }
    
    enum Model {
        case cheap, highQuality
        
        var name: String {
            switch self {
            case .cheap:
                return "gpt-4o-mini"
            case .highQuality:
                return "gpt-4o"
            }
        }
    }
    
    private static let apiKey: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let url = home.appending(path: "Developer/secrets/tools/OPENAI_API_KEY")
        let data = try! Data(contentsOf: url)
        return String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
    }()
    
    static func translate(task: Task, completion: @escaping (String) -> Void) {
        sendRequest(model: task.model, prompt: task.prompt) { response in
            completion(response!)
            print("✅ \(task.description)")
        }
    }
    
    private static func sendRequest(model: Model, prompt: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody: [String: Any] = [
            "model": model.name,
            "messages": [["role": "user", "content": prompt.trimmingCharacters(in: .whitespacesAndNewlines)]]
        ]
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String {
                completion(content.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "\"“"))))
            } else {
                print("🕰️ will retry in 30 seconds")
                queue.asyncAfter(deadline: .now() + .seconds(30)) {
                    sendRequest(model: model, prompt: prompt, completion: completion)
                }
            }
        }
        task.resume()
    }
    
}

extension AI.Task {
    var hash: String {
        let asString = prompt + model.name + description
        let data = asString.data(using: .utf8)
        return String(data!.fnv1aHash())
    }
}
