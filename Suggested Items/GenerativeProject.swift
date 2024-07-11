// ∅ nft-folder 2024

import Foundation

struct GenerativeProject: Codable {
    
    var id: String {
        return contractAddress + projectId
    }
    
    let contractAddress: String
    let projectId: String
    let tokens: [Token]
    let script: String
    let kind: Kind
    let instructions: String?
    
    enum Kind: String, Codable {
        case svg, js, p5js100, regl, twemoji, three, tone, paper
    }
    
    struct Token: Codable {
        
        let id: String
        let hash: String
        
    }
}
