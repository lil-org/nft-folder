// ∅ 2025 lil org

import Foundation

struct Consts {
    
    private init() {}
    
    static let options = "options"
    static let host = "host"
    static let context = "context"
    static let layer = "layer"
    
}

struct AgentDefaults {
    
    private static let userDefaults = UserDefaults.standard
    
    static var pipWidth: Double {
        get {
            let stored = userDefaults.double(forKey: "pipWidth")
            return stored.isZero ? 300 : stored
        }
        set {
            userDefaults.set(newValue, forKey: "pipWidth")
        }
    }
    
}
