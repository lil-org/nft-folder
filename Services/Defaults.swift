// ∅ nft-folder 2024

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
            userDefaults.keepOnly(keys: ["cleanupVersion", "unlimitedFileSize", "downloadGlb", "hideFromMenuBar"])
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
    
    static func cleanupForWallet(_ wallet: WatchOnlyWallet) {
        for isAttested in [true, false] {
            userDefaults.removeObject(forKey: folderCidKey(wallet: wallet, isCidAttested: isAttested))
        }
    }
    
    static func addKnownFolderCid(_ cid: String, isCidAttested: Bool, for wallet: WatchOnlyWallet) {
        userDefaults.setValue(cid, forKey: folderCidKey(wallet: wallet, isCidAttested: isCidAttested))
    }
    
    static func isKnownCid(_ cid: String, wallet: WatchOnlyWallet) -> Bool {
        if userDefaults.string(forKey: folderCidKey(wallet: wallet, isCidAttested: true)) == cid {
            return true
        } else if userDefaults.string(forKey: folderCidKey(wallet: wallet, isCidAttested: false)) == cid {
            return true
        } else {
            return false
        }
    }
    
    private static func folderCidKey(wallet: WatchOnlyWallet, isCidAttested: Bool) -> String {
        return "folder-cid-\(wallet.address)\(isCidAttested ? "" : "-pending")"
    }
    
    static var didShowPlayerTutorial: Bool {
        get {
            userDefaults.bool(forKey: "didShowPlayerTutorial")
        }
        set {
            userDefaults.set(newValue, forKey: "didShowPlayerTutorial")
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
    
    static var downloadGlb: Bool {
        get {
            userDefaults.bool(forKey: "downloadGlb")
        }
        set {
            userDefaults.set(newValue, forKey: "downloadGlb")
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
    
    static var hideFromMenuBar: Bool {
        get {
            userDefaults.bool(forKey: "hideFromMenuBar")
        }
        set {
            userDefaults.set(newValue, forKey: "hideFromMenuBar")
        }
    }
    
}
