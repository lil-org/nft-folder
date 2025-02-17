// ∅ nft-folder 2025

import SwiftUI
import UIKit

@main
struct nft_folder_iosApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MobileCollectionsView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
    
}

private let feedbackShortcutItemType = "org.lil.nft-folder.feedback"

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem, shortcutItem.type == feedbackShortcutItemType {
            UIApplication.shared.open(.quickFeedbackMail)
        }
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if shortcutItem.type == feedbackShortcutItemType {
            UIApplication.shared.open(.quickFeedbackMail)
        }
        completionHandler(true)
    }
    
}
