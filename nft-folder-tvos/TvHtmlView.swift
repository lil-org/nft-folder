// ∅ nft-folder 2024

import SwiftUI
import UIKit

private var loadHtml: ((String) -> Void)?

struct TvHtmlView: UIViewRepresentable {
    
    let htmlString: String
    
    func makeUIView(context: Context) -> UIView {
        if let webViewClass = NSClassFromString("UIWebView"),
           let webViewObject = webViewClass as? NSObject.Type {
            let webView: AnyObject = webViewObject.init()
            loadHtml = { [weak webView] html in
                webView?.loadHTMLString(html, baseURL: nil)
            }
            return webView as? UIView ?? UIView()
        } else {
            return UIView()
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        loadHtml?(htmlString)
    }
    
}
