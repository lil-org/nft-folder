// ∅ 2025 lil org

import WebKit

extension WKWebView {
    
    static func forStatusBarPlayer() -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.suppressesIncrementalRendering = true
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.wantsLayer = true
        webView.layer?.backgroundColor = NSColor.clear.cgColor
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        return webView
    }
    
}
