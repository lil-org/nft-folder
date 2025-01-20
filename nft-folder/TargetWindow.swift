// ∅ 2025 lil org

import Cocoa
import QuartzCore
import WebKit

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
    let sourceWindow = SourceWindow()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
        let contextId = sourceWindow.getContextID()
        if contextId != 0 {
            _ = TargetWindow(sourceContextId: contextId)
        } else {
            print("Error: Invalid context ID received.")
        }
    }
}

func CGSMainConnectionID() -> UInt32 {
    let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "CGSMainConnectionID")
    typealias CGSMainConnectionIDFunc = @convention(c) () -> UInt32
    let function = unsafeBitCast(symbol, to: CGSMainConnectionIDFunc.self)
    return function()
}

let htmlString = """
<!DOCTYPE html>
<html>
<head>
    <style>
        body { margin: 0; overflow: hidden; background: #000; }
        .box {
            width: 100px;
            height: 100px;
            background: linear-gradient(45deg, #ff0000, #ff7300, #ffeb00, #00ff00, #0099ff, #4b0082, #8b00ff);
            position: absolute;
            animation: move 4s infinite alternate ease-in-out;
        }
        @keyframes move {
            from { transform: translate(50px, 50px); }
            to { transform: translate(250px, 400px); }
        }
    </style>
</head>
<body>
    <div class="box"></div>
</body>
</html>
"""
