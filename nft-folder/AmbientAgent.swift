// ∅ 2025 lil org

import Cocoa

struct AmbientAgent {
    
    private init() {}
    
    // Sender (in main app)
    static func start(generatedToken: GeneratedToken) {
        let helperName = "nft-folder-ambient.app"
        let helperPath = Bundle.main.bundlePath.appending("/Contents/Helpers/\(helperName)")
        let helperURL = URL(fileURLWithPath: helperPath)

        print("yo html length is", generatedToken.html.count)
        
        // Launch the agent
        NSWorkspace.shared.openApplication(at: helperURL, configuration: .init()) { app, error in
            if let error = error {
                NSLog("Failed to launch helper: \(error.localizedDescription)")
                return
            }
            // Give the agent time to set up its notification observer
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                // Encode token
                guard let data = try? JSONEncoder().encode(generatedToken),
                      let jsonString = String(data: data, encoding: .utf8) else {
                    NSLog("Failed to encode GeneratedToken.")
                    return
                }

                DistributedNotificationCenter.default().post(
                    name: Notification.Name("MyTokenNotification"),
                    object: jsonString // TODO: maybe it's not a good idea to post an entire json
                )
            }
        }
    }
    
}
