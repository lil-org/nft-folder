// ∅ nft-folder 2024

import Foundation

struct Defaults {
    
    private static let userDefaults = UserDefaults.standard
    
    static func performCleanup(version: Int) {
        if version < 1 {
            userDefaults.keepOnly(keys: ["cleanupVersion", "unlimitedFileSize", "downloadGlb", "hideFromMenuBar"])
        }
    }
    
    static var cleanupVersion: Int {
        get {
            userDefaults.integer(forKey: "cleanupVersion")
        }
        set {
            userDefaults.set(newValue, forKey: "cleanupVersion")
        }
    }
    
    static var unlimitedFileSize: Bool {
        get {
            userDefaults.bool(forKey: "unlimitedFileSize")
        }
        set {
            userDefaults.set(newValue, forKey: "unlimitedFileSize")
        }
    }
    
    static var downloadGlb: Bool {
        get {
            userDefaults.bool(forKey: "downloadGlb")
        }
        set {
            userDefaults.set(newValue, forKey: "downloadGlb")
        }
    }
    
    static var hideFromMenuBar: Bool {
        get {
            userDefaults.bool(forKey: "hideFromMenuBar")
        }
        set {
            userDefaults.set(newValue, forKey: "hideFromMenuBar")
        }
    }
    
}
