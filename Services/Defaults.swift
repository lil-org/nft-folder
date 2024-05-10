// ∅ nft-folder 2024

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
    
    static var hideFromMenuBar: Bool {
        get {
            userDefaults.bool(forKey: "hideFromMenuBar")
        }
        set {
            userDefaults.set(newValue, forKey: "hideFromMenuBar")
        }
    }
    
    static var controlCenterWindowFrame: CGRect {
        get {
            let width = userDefaults.double(forKey: "controlCenterWindow.width")
            let height = userDefaults.double(forKey: "controlCenterWindow.height")
            let x = userDefaults.double(forKey: "controlCenterWindow.x")
            let y = userDefaults.double(forKey: "controlCenterWindow.y")
            if width > 0 && height > 0 {
                return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
            } else {
                return CGRect(origin: .zero, size: CGSize(width: 300, height: 420))
            }
        }
        set {
            userDefaults.set(newValue.width, forKey: "controlCenterWindow.width")
            userDefaults.set(newValue.height, forKey: "controlCenterWindow.height")
            userDefaults.set(newValue.origin.x, forKey: "controlCenterWindow.x")
            userDefaults.set(newValue.origin.y, forKey: "controlCenterWindow.y")
        }
    }
    
}
