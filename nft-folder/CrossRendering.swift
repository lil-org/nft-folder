import Cocoa
import QuartzCore
import Metal

func CGSMainConnectionID() -> UInt32 {
    let symbol = dlsym(UnsafeMutableRawPointer(bitPattern: -2), "CGSMainConnectionID")
    typealias CGSMainConnectionIDFunc = @convention(c) () -> UInt32
    let function = unsafeBitCast(symbol, to: CGSMainConnectionIDFunc.self)
    return function()
}

class MetalRenderer {
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    
    init?(device: MTLDevice) {
        self.device = device
        guard let queue = device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
    }
    
    func render(to drawable: CAMetalDrawable) {
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 1.0, 0.0, 1.0)  // Green color
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        renderEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

class SourceMetalWindow: NSWindow {
    var metalLayer: CAMetalLayer!
    var remoteContext: AnyObject?
    var contextId: UInt32 = 0
    var metalRenderer: MetalRenderer?
    
    init() {
        let frame = NSMakeRect(100, 100, 600, 400)
        super.init(
            contentRect: frame,
            styleMask: [.titled, .resizable, .closable],
            backing: .buffered,
            defer: false
        )
        self.title = "Metal Source Window"
        self.makeKeyAndOrderFront(nil)
        self.contentView?.wantsLayer = true
        
        setupMetalLayer()
        setupLayerSharing()
        renderLoop()
    }
    
    private func setupMetalLayer() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("Metal device not available")
            return
        }

        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
        metalLayer.frame = self.contentView!.bounds
        metalLayer.backgroundColor = NSColor.blue.cgColor

        self.contentView?.layer?.addSublayer(metalLayer)
        self.contentView?.layer?.backgroundColor = NSColor.gray.cgColor

        metalRenderer = MetalRenderer(device: device)
        
        addPlaceholderAnimation()
    }

    private func addPlaceholderAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(point: NSMakePoint(100, 100))
        animation.toValue = NSValue(point: NSMakePoint(400, 300))
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        let animatedLayer = CALayer()
        animatedLayer.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        animatedLayer.backgroundColor = NSColor.red.cgColor
        metalLayer.addSublayer(animatedLayer)
        
        animatedLayer.add(animation, forKey: "positionAnimation")
    }
    
    private func setupLayerSharing() {
        let connectionId = CGSMainConnectionID()
        let options: NSDictionary = [:]
        
        if let contextClass = NSClassFromString("CAContext") as? NSObject.Type,
           let contextInstance = contextClass.perform(Selector(("contextWithCGSConnection:options:")), with: connectionId, with: options)?.takeUnretainedValue() {
            remoteContext = contextInstance
            remoteContext?.setValue(metalLayer, forKey: "layer")
            
            if let retrievedContextId = remoteContext?.value(forKey: "contextId") as? UInt32 {
                contextId = retrievedContextId
                print("Renderer: CAContext's layer set for export with ID \(contextId).")
            } else {
                print("Failed to retrieve CAContext ID.")
            }
        } else {
            print("Failed to create CAContext.")
        }
    }
    
    private func renderLoop() {
        Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            autoreleasepool {
                if let drawable = self.metalLayer.nextDrawable() {
                    self.metalRenderer?.render(to: drawable)
                }
            }
        }
    }
    
    func getContextID() -> UInt32 {
        return contextId
    }
}

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
        self.title = "Metal Target Window"
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
    let sourceWindow = SourceMetalWindow()
    let contextId = sourceWindow.getContextID()
    
    if contextId != 0 {
        _ = TargetWindow(sourceContextId: contextId)
    } else {
        print("Error: Invalid context ID received.")
    }
}
