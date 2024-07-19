// ∅ nft-folder 2024

import WebKit

class WebViewWithMenu: WKWebView {
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setupRightClickGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupRightClickGesture()
    }
    
    private func setupRightClickGesture() {
        let rightClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleRightClick(_:)))
        rightClickGestureRecognizer.buttonMask = 0x2
        addGestureRecognizer(rightClickGestureRecognizer)
    }
    
    @objc private func handleRightClick(_ gestureRecognizer: NSClickGestureRecognizer) {
        // TODO: handle action and show menu
         // popUpMenu()
    }
    
    private func popUpMenu() {
        // TODO: more items
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Back", action: #selector(backItemSelected), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Forward", action: #selector(forwardItemSelected), keyEquivalent: ""))
        if let event = NSApp.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: self)
        }
    }
    
    @objc private func backItemSelected() {
        print("back")
    }
    
    @objc private func forwardItemSelected() {
        print("forward")
    }
}
