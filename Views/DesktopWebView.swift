// ∅ nft-folder 2024

import SwiftUI
import WebKit

struct DesktopWebView: NSViewRepresentable {
    
    var htmlContent: String
    
    func makeNSView(context: Context) -> NSView {
        let containerView = NSView()
        DispatchQueue.main.async { [weak containerView] in
            let webConfiguration = WKWebViewConfiguration()
            webConfiguration.suppressesIncrementalRendering = true
            let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
            wkWebView.translatesAutoresizingMaskIntoConstraints = false
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
