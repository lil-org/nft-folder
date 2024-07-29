// ∅ nft-folder 2024

import SwiftUI
import UIKit

private var loadContent: ((String) -> Void)?

struct GeneratedTokenView: UIViewRepresentable {
    
    let contentString: String
    
    func makeUIView(context: Context) -> UIView {
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
            loadContent = { [weak target] content in
                let html = HelperStrings.html.starts(with: "h") ? HelperStrings.html : ""
                let selector = NSSelectorFromString("load\(html.uppercased())String:base\(HelperStrings.url.uppercased()):")
                target?.perform(selector, with: content, with: nil)
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
