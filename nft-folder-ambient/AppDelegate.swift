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
        let windowRect = NSRect(x: 0, y: 0, width: 800, height: 600)

        window = NSWindow(
            contentRect: windowRect,
            styleMask: [.titled, .closable, .resizable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window?.isReleasedWhenClosed = false
        window?.center()

        let viewController = ViewController()
        window?.contentViewController = viewController
        window?.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
}
