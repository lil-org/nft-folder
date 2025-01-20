// ∅ 2025 lil org

import Cocoa
import QuartzCore
import WebKit

var sharedSourceWindow: SourceWindow?

class TargetWindow: NSWindow {
    
    var layerHost: AnyObject?
    
    init(sourceContextId: UInt32) {
        let frame = NSMakeRect(750, 100, 600, 400)
        super.init(
            contentRect: frame,
            styleMask: [.titled, .resizable, .closable],
            backing: .buffered,
            defer: false
        )
        self.title = "Target Window"
        self.makeKeyAndOrderFront(nil)
        self.contentView?.wantsLayer = true
        self.contentView?.layer?.backgroundColor = NSColor.red.cgColor
        
        setupLayerHost(with: sourceContextId)
    }
    
    private func setupLayerHost(with contextId: UInt32) {
        if let layerHostClass = NSClassFromString("CALayerHost") as? NSObject.Type {
            layerHost = layerHostClass.init()
            layerHost?.setValue(contextId, forKey: "contextId")
            
            if let castedLayerHost = layerHost as? CALayer {
                castedLayerHost.frame = self.contentView!.bounds
                self.contentView?.layer?.addSublayer(castedLayerHost)
                print("Renderer: Displaying remote layer with context ID \(contextId).")
            } else {
                print("Failed to cast CALayerHost.")
            }
        } else {
            print("Failed to create CALayerHost.")
        }
    }
}

func setupWindows() {
    sharedSourceWindow = SourceWindow()
}
