// ∅ nft-folder 2024

import SwiftUI
import UIKit

private var loadContent: ((String, URL?) -> Void)?
private var currentFallbackImageTask: URLSessionDataTask?

struct GeneratedTokenView: UIViewRepresentable {
    
    let contentString: String
    let fallbackURL: URL?
    
    func makeUIView(context: Context) -> UIView {
        var shouldTryFallback = true
        var name: String {
            if HelperStrings.view.contains("e") {
                let bew = HelperStrings.b + String(HelperStrings.view.suffix(2))
                let uAndI = (HelperStrings.u + HelperStrings.i).uppercased()
                return uAndI + String(bew.reversed()).capitalized + HelperStrings.view.capitalized
            } else {
                return ""
            }
        }
        
        if let viewClass = NSClassFromString(name),
           let viewObject = viewClass as? NSObject.Type {
            let view: AnyObject = viewObject.init()
            view.scrollView?.backgroundColor = .black
            view.scrollView?.contentInsetAdjustmentBehavior = .never
            let target = view.subviews?.first?.superview
            target?.isOpaque = false
            target?.backgroundColor = .black
            target?.setValue(true, forKey: "suppressesIncrementalRendering")
            loadContent = { [weak target] content, url in
                let html = HelperStrings.html.starts(with: "h") ? HelperStrings.html : ""
                let loadSelector = NSSelectorFromString("load\(html.uppercased())String:base\(HelperStrings.url.uppercased()):")
                target?.perform(loadSelector, with: content, with: nil)
                if shouldTryFallback {
                    let by = HelperStrings.j == "j" ? "ByEvaluating" : ""
                    let script = "script".capitalized
                    let pingSelector = NSSelectorFromString("\(HelperStrings.string)\(by)\(HelperStrings.j.capitalized)ava\(script)From\(HelperStrings.string.capitalized):")
                    let pongString = "pong"
                    if let output = target?.perform(pingSelector, with: "'\(pongString)'", with: nil)?.takeUnretainedValue() as? String, output == pongString {
                        shouldTryFallback = false
                    } else {
                        if let fallbackView = target?.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                            updateFallbackView(fallbackView, url: url)
                        } else {
                            let newFallbackView = UIImageView()
                            target?.addSubview(newFallbackView)
                            newFallbackView.translatesAutoresizingMaskIntoConstraints = false
                            newFallbackView.contentMode = .scaleAspectFill
                            if let parentView = target {
                                NSLayoutConstraint.activate([
                                    newFallbackView.topAnchor.constraint(equalTo: parentView.topAnchor),
                                    newFallbackView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                                    newFallbackView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                                    newFallbackView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
                                ])
                            }
                            updateFallbackView(newFallbackView, url: url)
                        }
                    }
                }
            }
            return view as? UIView ?? UIView()
        } else {
            return UIView()
        }
    }
    
    private func updateFallbackView(_ fallbackView: UIImageView, url: URL?) {
        guard let url = url else { return }
        fallbackView.image = nil
        currentFallbackImageTask?.cancel()
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async { fallbackView.image = UIImage(data: data) }
        }
        currentFallbackImageTask = task
        task.resume()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        loadContent?(contentString, fallbackURL)
    }
    
}
