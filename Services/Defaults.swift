// ∅ 2025 lil org

import Foundation

struct Defaults {
    
    private static let userDefaults = UserDefaults.standard
    
    static func eraseAllContent() {
        let dictionary = userDefaults.dictionaryRepresentation()
        for key in dictionary.keys where key != "cleanupVersion" {
            userDefaults.removeObject(forKey: key)
        }
    }
    
    static func performCleanup(version: Int) {
        if version < 1 {
            userDefaults.keepOnly(keys: ["cleanupVersion", "unlimitedFileSize"])
        }
    }
    
    static var suggestedItemsToHide: [String] {
        get {
            userDefaults.array(forKey: "suggestedItemsToHide") as? [String] ?? []
        }
        set {
            userDefaults.set(newValue, forKey: "suggestedItemsToHide")
        }
    }
    
    static func cleanupForWallet(_ wallet: WatchOnlyWallet) {}
    
    static var didShowTvPlayerTutorial: Bool {
        get {
            userDefaults.bool(forKey: "didShowTvPlayerTutorial")
        }
        set {
            userDefaults.set(newValue, forKey: "didShowTvPlayerTutorial")
        }
    }
    
    static var preferresInfoPopoverHidden: Bool {
        get {
            userDefaults.bool(forKey: "preferresInfoPopoverHidden")
        }
        set {
            userDefaults.set(newValue, forKey: "preferresInfoPopoverHidden")
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
    
    static var downloadAudio: Bool {
        get {
            userDefaults.bool(forKey: "downloadAudio")
        }
        set {
            userDefaults.set(newValue, forKey: "downloadAudio")
        }
    }
    
    static var downloadVideo: Bool {
        get {
            userDefaults.bool(forKey: "downloadVideo")
        }
        set {
            userDefaults.set(newValue, forKey: "downloadVideo")
        }
    }
    
}
