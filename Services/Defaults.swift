// ∅ nft-folder-macos 2024

import Foundation

struct Defaults {
    
    private static let userDefaults = UserDefaults.standard

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
    
}

