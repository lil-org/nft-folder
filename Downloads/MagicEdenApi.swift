// ∅ 2025 lil org

import Foundation

struct MagicEdenApi {
    
    private static let urlSession = URLSession.shared
    private static let queue = DispatchQueue(label: "\(Bundle.hostBundleId).MagicEdenApi", qos: .default)
    
    static func get(owner: String) {
        // TODO: implement
    }
    
}
