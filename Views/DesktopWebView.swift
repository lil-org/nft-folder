// ∅ nft-folder 2024

import SwiftUI
import WebKit

struct DesktopWebView: NSViewRepresentable {
    
    var htmlContent: String
    @State private var webView: WKWebView?
    
    func makeNSView(context: Context) -> NSView {
        let containerView = NSView()
        DispatchQueue.main.async {
            let webConfiguration = WKWebViewConfiguration()
            webConfiguration.suppressesIncrementalRendering = true
            let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
            wkWebView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(wkWebView)
            NSLayoutConstraint.activate([
                wkWebView.topAnchor.constraint(equalTo: containerView.topAnchor),
                wkWebView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                wkWebView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                wkWebView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            wkWebView.loadHTMLString(htmlContent, baseURL: nil)
            self.webView = wkWebView
        }
        return containerView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        if let webView = webView {
            webView.loadHTMLString(htmlContent, baseURL: nil)
        }
    }
    
}
