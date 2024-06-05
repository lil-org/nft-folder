// ∅ nft-folder 2024

import Cocoa

struct Alerts {
    
    static func showConfirmation(message: String, text: String, completion: (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = text
        alert.alertStyle = .informational
        alert.addButton(withTitle: Strings.ok)
        alert.addButton(withTitle: Strings.cancel)
        alert.buttons.last?.keyEquivalent = "\u{1b}"
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            completion(true)
        default:
            break
        }
    }
    
    static func showSomethingWentWrong() {
        let alert = NSAlert()
        alert.messageText = Strings.somethingWentWrong
        alert.alertStyle = .warning
        _ = alert.runModal()
    }
    
}
