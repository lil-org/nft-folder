// ∅ 2025 lil org

import Cocoa

// TODO: create a hidden window with PipPlaceholderOverlay().frame(width: 1, height: 1).position(x: 0, y: 0)

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createMainWindow()
    }

    private func createMainWindow() {
        let windowRect = NSRect(x: 0, y: 0, width: 1, height: 1) // TODO: try 0, 0 too
        
        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window?.isReleasedWhenClosed = false
        window?.center()
        window?.level = .floating
        window?.isMovable = false
        window?.ignoresMouseEvents = true
        window?.backgroundColor = .clear

        let viewController = ViewController()
        window?.contentViewController = viewController
        window?.makeKeyAndOrderFront(nil)
        window?.contentView?.isHidden = true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
}
