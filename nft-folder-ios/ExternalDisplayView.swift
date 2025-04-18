// ∅ 2025 lil org

import UIKit
import WebKit

fileprivate weak var currentDisplay: ExternalDisplayViewController?

func updateExternalDisplayToken(_ token: GeneratedToken) {
    currentDisplay?.renderToken(token)
}

class ExternalDisplayViewController: UIViewController {
    
    private var webView: WKWebView!
    private var currentToken = GeneratedToken.empty
    private var renderedTokenId = ""
    private var willOrDidAppear = false
    
    init() {
        super.init(nibName: nil, bundle: nil)
        currentDisplay = self
        renderCurrentItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("yo")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willOrDidAppear = true
        renderCurrentItem()
    }
    
    fileprivate func renderToken(_ token: GeneratedToken) {
        currentToken = token
        renderCurrentItem()
    }
    
    private func renderCurrentItem() {
        guard willOrDidAppear else { return }
        
        if webView == nil {
            webView = AutoReloadingWebView.new
            webView.isUserInteractionEnabled = false
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                webView.topAnchor.constraint(equalTo: view.topAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        if currentToken.id == renderedTokenId {
            return
        } else {
            renderedTokenId = currentToken.id
            webView.loadHTMLString(currentToken.html, baseURL: nil)
        }
    }
    
}
