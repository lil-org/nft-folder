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
    let screensaverFileName: String?
    
    enum Kind: String, Codable {
        case svg, js, p5js100, regl, twemoji, three, tone, paper, p5js190
    }
    
    struct Token: Codable {
        
        let id: String
        let hash: String
        
    }
    
    var screensaverUrl: URL? {
        if let fileName = screensaverFileName {
            return URL(string: "https://github.com/lil-org/screensavers/releases/download/1.0.0/\(fileName).zip")
        } else {
            return nil
        }
    }
    
}
