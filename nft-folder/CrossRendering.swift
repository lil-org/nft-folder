// ∅ 2025 lil org

import WebKit
import QuartzCore
import IOSurface

class SourceWebViewWindow: NSWindow {
    var webView: WKWebView!
    
    init() {
        let frame = NSMakeRect(100, 100, 600, 400)
        super.init(
            contentRect: frame,
            styleMask: [.titled, .resizable, .closable],
            backing: .buffered,
            defer: false
        )
        self.title = "WebView Window"
        self.makeKeyAndOrderFront(nil)
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.backgroundColor = NSColor.gray.cgColor
        setupWebView()
    }
    
    private func setupWebView() {
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: self.contentView!.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        self.contentView?.addSubview(webView)
        
        let html = """
        <html>
        <body style=\"background:green;\">
            <div style=\"position:absolute; width:100px; height:100px; background:red; animation:move 2s infinite alternate;\"></div>
            <style>@keyframes move { from { left: 0px; top: 0px; } to { left: 200px; top: 200px; } }</style>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }
}

class TargetWindow: NSWindow {
    init() {
        let frame = NSMakeRect(750, 100, 600, 400)
        super.init(
            contentRect: frame,
            styleMask: [.titled, .resizable, .closable],
            backing: .buffered,
            defer: false
        )
        self.title = "Target Render Window"
        self.makeKeyAndOrderFront(nil)
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.backgroundColor = NSColor.gray.cgColor
    }
}

func setupWindows() {
    let _ = SourceWebViewWindow()
    let _ = TargetWindow()
}
