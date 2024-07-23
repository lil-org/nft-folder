// ∅ nft-folder 2024

import Foundation

struct Script: Codable {
    
    let value: String
    let kind: Kind
    let instructions: String?
    let screensaverFileName: String?
    
    enum Kind: String, Codable {
        case svg, js, p5js100, regl, twemoji, three, tone, paper, p5js190
    }
    
    var screensaverUrl: URL? {
        if let fileName = screensaverFileName {
            return URL(string: "https://github.com/lil-org/screen-savers/releases/download/1.0.0/\(fileName).zip")
        } else {
            return nil
        }
    }
    
}
