import Cocoa
import QuartzCore
import Metal
import WebKit

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
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        
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
    var displayLink: CADisplayLink?
    var webView: WKWebView!

    init() {
        let frame = NSMakeRect(100, 100, 800, 600)
        super.init(
            contentRect: frame,
            styleMask: [.titled, .resizable, .closable],
            backing: .buffered,
            defer: false
        )
        self.title = "Source Window"
        self.makeKeyAndOrderFront(nil)
        self.contentView?.wantsLayer = true
        
        setupMetalLayer()
        setupLayerSharing()
        setupWebView()
        startRendering()
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
        metalLayer.frame = NSRect(x: 0, y: 0, width: 400, height: 600)
        metalLayer.backgroundColor = NSColor.blue.cgColor
        metalLayer.isOpaque = true
        metalLayer.drawableSize = metalLayer.frame.size

        self.contentView?.layer?.addSublayer(metalLayer)
        self.contentView?.layer?.backgroundColor = NSColor.gray.cgColor

        metalRenderer = MetalRenderer(device: device)
        
        addPlaceholderAnimation()
    }

    private func addPlaceholderAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(point: NSMakePoint(100, 100))
        animation.toValue = NSValue(point: NSMakePoint(300, 300))
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
    
    private func setupWebView() {
        let webViewFrame = NSRect(x: 0, y: 0, width: 400, height: 600)
        webView = WKWebView(frame: webViewFrame)
        
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

        webView.loadHTMLString(htmlString, baseURL: nil)
        self.contentView?.addSubview(webView)
    }
    
    private func startRendering() {
        guard let contentView = self.contentView else {
            print("Content view is nil")
            return
        }
        
        displayLink = contentView.displayLink(target: self, selector: #selector(renderFrame))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func renderFrame() {
        autoreleasepool {
            if let drawable = metalLayer.nextDrawable() {
                metalRenderer?.render(to: drawable)
            }
        }
    }

    func getContextID() -> UInt32 {
        return contextId
    }

    deinit {
        displayLink?.invalidate()
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
