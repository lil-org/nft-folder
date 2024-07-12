// ∅ nft-folder 2024

import ScreenSaver
import WebKit

class NftScreenSaverView: ScreenSaverView {
    
    private var webView: WKWebView?
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setupWebView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWebView()
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: bounds, configuration: webConfiguration)
        if let webView = webView {
            addSubview(webView)
            webView.autoresizingMask = [.width, .height]
            webView.loadHTMLString(generateHtml(), baseURL: nil)
        }
    }
    
}
