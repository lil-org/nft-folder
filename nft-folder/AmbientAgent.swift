// ∅ 2025 lil org

import Cocoa

struct AmbientAgent {
    
    private init() {}
    
    static func start() {
        let helperName = "nft-folder-ambient.app"
        let helperPath = Bundle.main.bundlePath.appending("/Contents/Helpers/\(helperName)")
        let helperURL = URL(fileURLWithPath: helperPath)
        NSWorkspace.shared.openApplication(at: helperURL, configuration: .init())
    }
    
}
