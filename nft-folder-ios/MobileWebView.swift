// ∅ 2025 lil org

import SwiftUI
import WebKit

struct MobileWebView: UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        return MobileWebView.makeNewWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    static func makeNewWebView() -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.suppressesIncrementalRendering = true
        let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.isOpaque = false
        wkWebView.backgroundColor = .black
        wkWebView.scrollView.backgroundColor = .black
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        wkWebView.configuration.userContentController.addUserScript(WKUserScript(source: "document.addEventListener('contextmenu', function(e) { e.preventDefault(); }, false);", injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        return wkWebView
    }
}
