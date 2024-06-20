// ∅ nft-folder 2024

import SwiftUI

struct FirstMouseView: NSViewRepresentable {
    
    func makeNSView(context: Context) -> NSView {
        return FirstMouseBackingView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
    
}

class FirstMouseBackingView: NSView {
    
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
    
}
