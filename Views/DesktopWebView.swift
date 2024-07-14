// ∅ nft-folder 2024

import SwiftUI
import WebKit

struct DesktopWebView: NSViewRepresentable {
    
    var htmlContent: String
    
    func makeNSView(context: Context) -> NSView {
        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = .black
        DispatchQueue.main.async { [weak containerView] in
            let webConfiguration = WKWebViewConfiguration()
            webConfiguration.suppressesIncrementalRendering = true
            let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
            wkWebView.wantsLayer = true
            wkWebView.layer?.backgroundColor = .black
            wkWebView.translatesAutoresizingMaskIntoConstraints = false
            wkWebView.setValue(true, forKey: "drawsTransparentBackground")
            wkWebView.configuration.userContentController.addUserScript(WKUserScript(source: "document.addEventListener('contextmenu', function(e) { e.preventDefault(); }, false);", injectionTime: .atDocumentEnd, forMainFrameOnly: true))
            if let containerView = containerView {
                containerView.addSubview(wkWebView)
                NSLayoutConstraint.activate([
                    wkWebView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    wkWebView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    wkWebView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                    wkWebView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
                ])
                wkWebView.loadHTMLString(htmlContent, baseURL: nil)
            }
        }
        return containerView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            if let wkWebView = nsView.subviews.first as? WKWebView {
                wkWebView.loadHTMLString(htmlContent, baseURL: nil)
            }
        }
    }
    
}
