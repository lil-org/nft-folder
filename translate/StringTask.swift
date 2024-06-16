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
        let output = """
        help me localize macos app that downloads nfts.
        
        translate the string to \(language.name).
        
        feel free to tune it to make \(language.name) version sound natural.
        
        use both english and russian versions below as a reference.
        
        english:
        "\(englishText)"
        
        russian:
        "\(russianText)"
                
        keep it simple and straightforward.
                    
        keep formatting, capitalization, and punctuation style close to the original.
        
        respond only with \(language.name) version. do not add anything else to the response.
        """
        
        return output
    }
    
}
