// ∅ 2025 lil org

import UIKit
import WebKit

fileprivate weak var currentDisplay: ExternalDisplayViewController?
fileprivate var currentToken = GeneratedToken.empty

func updateExternalDisplayToken(_ token: GeneratedToken) {
    currentToken = token
    currentDisplay?.renderCurrentItem()
}

class ExternalDisplayViewController: UIViewController {
    
    private var webView: WKWebView!
    private var placeholderStack: UIStackView!
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        willOrDidAppear = true
        renderCurrentItem()
    }
    
    private func ensurePlaceholder() {
        guard placeholderStack == nil else { return }
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 27
        let icons = (Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any])?["CFBundlePrimaryIcon"] as? [String: Any]
        let iconFiles = icons?["CFBundleIconFiles"] as? [String]
        imageView.image = UIImage(named: iconFiles?.last ?? "AppIcon")
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Select something in the app."
        label.font = .preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        
        placeholderStack = UIStackView(arrangedSubviews: [imageView, label])
        placeholderStack.translatesAutoresizingMaskIntoConstraints = false
        placeholderStack.axis = .vertical
        placeholderStack.spacing = 34
        placeholderStack.alignment = .center
        placeholderStack.overrideUserInterfaceStyle = .dark
        view.addSubview(placeholderStack)
        
        NSLayoutConstraint.activate([
            placeholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 192),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    fileprivate func renderCurrentItem() {
        guard willOrDidAppear else { return }
        
        let isEmpty = currentToken.html.isEmpty
        ensurePlaceholder()
        
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
        
        placeholderStack.isHidden = !isEmpty
        webView.isHidden = isEmpty
        
        if currentToken.id == renderedTokenId {
            return
        } else {
            renderedTokenId = currentToken.id
            webView.loadHTMLString(currentToken.html, baseURL: nil)
        }
    }
    
}
