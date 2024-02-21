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
    
    static var controlCenterWindowSize: CGSize {
        get {
            let width = userDefaults.double(forKey: "controlCenterWindowSize.width")
            let height = userDefaults.double(forKey: "controlCenterWindowSize.height")
            if width > 0 && height > 0 {
                return CGSize(width: width, height: height)
            } else {
                return CGSize(width: 300, height: 400)
            }
        }
        set {
            userDefaults.set(newValue.width, forKey: "controlCenterWindowSize.width")
            userDefaults.set(newValue.height, forKey: "controlCenterWindowSize.height")
        }
    }
    
}

