// nft-folder-macos 2023 ethistanbul

import Foundation

extension Encodable {
    
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else {
            return nil
        }
        
        return json
    }
    
}

extension Decodable {
    
    static func from(_ object: Any?) -> Self? {
        if let dict = object as? [String: Any],
           let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let decoded = try? JSONDecoder().decode(Self.self, from: data) {
            return decoded
        } else {
            return nil
        }
    }
    
}
