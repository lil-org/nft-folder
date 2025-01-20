import Cocoa
import QuartzCore
import WebKit

class SourceWindow: NSWindow {
    
    private var sourceLayer: CALayer!
    private var remoteContext: AnyObject?
    private var contextId: UInt32 = 0
    
    private var webView: WKWebView!
    
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
        
        setupSourceLayer()
        
        setupWebView()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.setupLayerSharing()
        }
    }
    
    private func setupWebView() {
        let webViewFrame = NSRect(x: 0, y: 0, width: 1000, height: 1000)
        webView = WKWebView(frame: webViewFrame)
        webView.wantsLayer = true
        webView.loadHTMLString(htmlString, baseURL: nil)
        self.contentView?.addSubview(webView)
    }
    
    private func setupSourceLayer() {
        sourceLayer = CALayer()
        sourceLayer.frame = NSRect(x: 0, y: 0, width: 400, height: 600)
        sourceLayer.backgroundColor = NSColor.blue.cgColor
        sourceLayer.cornerRadius = 20.0
        sourceLayer.borderColor = NSColor.white.cgColor
        sourceLayer.borderWidth = 5.0
        
        self.contentView?.layer?.addSublayer(sourceLayer)
        self.contentView?.layer?.backgroundColor = NSColor.gray.cgColor
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(point: NSMakePoint(100, 100))
        animation.toValue = NSValue(point: NSMakePoint(300, 300))
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        
        let animatedLayer = CALayer()
        animatedLayer.frame = CGRect(x: 50, y: 50, width: 100, height: 100)
        animatedLayer.backgroundColor = NSColor.red.cgColor
        sourceLayer.addSublayer(animatedLayer)
        
        animatedLayer.add(animation, forKey: "positionAnimation")
    }
    
}

extension SourceWindow {
    
    func setupLayerSharing() {
        let connectionId = CGSMainConnectionID()
        let options: NSDictionary = [:]
        
        if let contextClass = NSClassFromString("CAContext") as? NSObject.Type,
           let contextInstance = contextClass.perform(Selector(("remoteContextWithOptions:")), with: options)?.takeUnretainedValue() {
            remoteContext = contextInstance
            remoteContext?.setValue(webView.layer, forKey: "layer")
            
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
    
    func getContextID() -> UInt32 {
        return contextId
    }
    
}
