// ∅ nft-folder 2024

import SwiftUI
import WebKit

struct DesktopWebView: NSViewRepresentable {
    
    var htmlContent: String
    
    func makeNSView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
}
