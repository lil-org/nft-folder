// ∅ nft-folder 2024

import Foundation

struct StringTask: AI.Task {
    
    let model: AI.Model
    let language: Language
    let englishText: String
    let russianText: String
    
    var description: String {
        return "\(language.name) \(englishText)"
    }
    
    var prompt: String {
        // TODO: tune prompt
        
        let output = """
        translate the string to \(language.name).
        
        keep it simple and straightforward.
        
        use both english and russian versions below as a reference.
        
        english:
        "\(englishText)"
        
        russian:
        "\(russianText)"
        
        respond only with a \(language.name) version. do not add anything else to the response.
        """
        
        return output
    }
    
}
