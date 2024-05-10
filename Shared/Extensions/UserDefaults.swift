// ∅ nft-folder 2024

import Foundation

extension UserDefaults {
    
    func keepOnly(keys: [String]) {
        let accessedKeys = Set(keys)
        for (key, _) in dictionaryRepresentation() {
            if !accessedKeys.contains(key) {
                removeObject(forKey: key)
            }
        }
    }
    
}
