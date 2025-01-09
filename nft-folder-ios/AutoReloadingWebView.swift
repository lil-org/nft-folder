// ∅ 2025 lil org

import SwiftUI
import WebKit

class AutoReloadingWebView: WKWebView {
    
    private var lastLoadedHtmlString: String?
    private var loadedForBounds: CGRect?
    
    static var new: AutoReloadingWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.suppressesIncrementalRendering = true
        let wkWebView = AutoReloadingWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.isOpaque = false
        wkWebView.backgroundColor = .black
        wkWebView.scrollView.backgroundColor = .black
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        wkWebView.configuration.userContentController.addUserScript(WKUserScript(source: "document.addEventListener('contextmenu', function(e) { e.preventDefault(); }, false);", injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        return wkWebView
    }
    
    override var bounds: CGRect {
        didSet {
            if bounds != oldValue, let html = lastLoadedHtmlString {
                loadHTMLString(html, baseURL: nil)
            }
        }
    }
    
    override var frame: CGRect {
        didSet {
            if frame != oldValue, let html = lastLoadedHtmlString {
                loadHTMLString(html, baseURL: nil)
            }
        }
    }
    
    @discardableResult override func loadHTMLString(_ string: String, baseURL: URL?) -> WKNavigation? {
        let newHtmlContent = lastLoadedHtmlString != string
        let newBounds = bounds != loadedForBounds
        
        if newHtmlContent {
            lastLoadedHtmlString = string
        }
        
        loadedForBounds = bounds
        
        if !hasVisibleSize {
            stopLoading()
        }
        
        guard hasVisibleSize, newBounds || newHtmlContent else { return nil }
        return super.loadHTMLString(string, baseURL: baseURL)
    }
    
    private var hasVisibleSize: Bool {
        return bounds.size.width > 5 && bounds.size.height > 5
    }
    
}
