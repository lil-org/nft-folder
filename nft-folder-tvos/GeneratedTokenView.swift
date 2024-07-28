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
            // TODO: fix bg
            loadContent = { [weak view] content in
                view?.loadHTMLString(content, baseURL: nil)
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
