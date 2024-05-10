// ∅ nft-folder 2024

import Cocoa
import SwiftUI

class ClickHandlerView: NSView {
    
    var onClick: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addGestureRecognizer(NSClickGestureRecognizer(target: self, action: #selector(click)))
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    @objc private func click() {
        onClick?()
    }
    
}

struct ClickHandler: NSViewRepresentable {
    
    var onClick: () -> Void
    
    func makeNSView(context: Context) -> ClickHandlerView {
        let view = ClickHandlerView()
        view.onClick = onClick
        return view
    }
    
    func updateNSView(_ nsView: ClickHandlerView, context: Context) {
        nsView.onClick = onClick
    }
    
}
