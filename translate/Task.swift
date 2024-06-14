// ∅ nft-folder 2024

import Foundation

struct Task {
    
    let model: AI.Model
    let metadataKind: MetadataKind
    let language: Language
    let englishText: String
    let russianText: String
    
    var prompt: String {
        // TODO: tune prompt for different metadata
        // A description of your app, detailing features and functionality.
        // Separate keywords with an English comma, Chinese comma, or a mix of both.
        // max 100 chars for keywords
        // Describe what's new in this version of your app, such as new features, improvements, and bug fixes.
        
        let metadataName = "text" // TODO: vary based on metadataKind
        return """
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
    }
    
    var wasCompletedBefore: Bool {
        if let data = try? Data(contentsOf: hashURL),
           let text = String(data: data, encoding: .utf8) {
            return hash == text
        } else {
            return false
        }
    }
    
    func storeAsCompleted() {
        let data = hash.data(using: .utf8)!
        try! data.write(to: hashURL)
    }
    
    private var hashURL: URL {
        return URL(fileURLWithPath: projectDir + "/translate/latest/" + "\(language.metadataLocalizationKey)-\(metadataKind.fileName)")
    }
    
    private var hash: String {
        let description = prompt + model.name
        let data = description.data(using: .utf8)
        return String(data!.fnv1aHash())
    }
    
}
