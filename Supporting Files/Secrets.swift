// nft-folder-macos 2024

import Foundation

struct Secrets {
    
    static let inchApiKey: String = {
        if let apiKey = plist["1inch"] as? String, !apiKey.isEmpty {
            return apiKey
        } else {
            fatalError("get api key at https://portal.1inch.dev")
        }
    }()
    
    private static let plist: [String: AnyObject] = {
        let path = Bundle.main.path(forResource: "Secrets", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path) as! [String: AnyObject]
        return dict
    }()
    
}
