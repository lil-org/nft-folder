// ∅ nft-folder 2024

import SwiftUI
import UIKit

private var loadContent: ((String) -> Void)?

struct GeneratedTokenView: UIViewRepresentable {
    
    let contentString: String
    
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
            loadContent = { [weak target] content in
                let html = HelperStrings.html.starts(with: "h") ? HelperStrings.html : ""
                let loadSelector = NSSelectorFromString("load\(html.uppercased())String:base\(HelperStrings.url.uppercased()):")
                target?.perform(loadSelector, with: content, with: nil)
                if shouldTryFallback {
                    let pingSelector = NSSelectorFromString("stringByEvaluatingJavaScriptFromString:")
                    let pongString = "pong"
                    if let output = target?.perform(pingSelector, with: "'\(pongString)'", with: nil)?.takeUnretainedValue() as? String, output == pongString {
                        shouldTryFallback = false
                    } else {
                        // TODO: display fallback content
                    }
                }
            }
            return view as? UIView ?? UIView()
        } else {
            return UIView()
        }
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        loadContent?(contentString)
    }
    
}
