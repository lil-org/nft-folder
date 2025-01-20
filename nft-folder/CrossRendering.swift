// ∅ 2025 lil org

import WebKit
import QuartzCore
import IOSurface

var mainWindow: NSWindow!
var secondWindow: NSWindow!
var webView: WKWebView!

func setupWindows() {
    mainWindow = createWindow(title: "WebView Window", frame: NSMakeRect(100, 100, 600, 400))
    secondWindow = createWindow(title: "Target Render Window", frame: NSMakeRect(750, 100, 600, 400))
    setupWebView()
}

func createWindow(title: String, frame: NSRect) -> NSWindow {
    let window = NSWindow(
        contentRect: frame,
        styleMask: [.titled, .resizable, .closable],
        backing: .buffered,
        defer: false
    )
    window.title = title
    window.makeKeyAndOrderFront(nil)
    window.contentView?.wantsLayer = true
    window.contentView?.layer?.backgroundColor = NSColor.gray.cgColor
    return window
}

func setupWebView() {
    let config = WKWebViewConfiguration()
    webView = WKWebView(frame: mainWindow.contentView!.bounds, configuration: config)
    webView.autoresizingMask = [.width, .height]
    mainWindow.contentView?.addSubview(webView)

    let html = """
    <html>
    <body style="background:green;">
        <div style="position:absolute; width:100px; height:100px; background:red; animation:move 2s infinite alternate;"></div>
        <style>@keyframes move { from { left: 0px; top: 0px; } to { left: 200px; top: 200px; } }</style>
    </body>
    </html>
    """
    webView.loadHTMLString(html, baseURL: nil)
}
