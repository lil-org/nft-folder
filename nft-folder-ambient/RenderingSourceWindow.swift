import Cocoa
import QuartzCore
import WebKit

class RenderingSourceWindow: NSWindow {
    
    private var sourceLayer: CALayer!
    private var remoteContext: AnyObject?
    private var contextId: UInt32 = 0
    
    private var webView: WKWebView?
    
    init() {
        let frame = NSMakeRect(0, 0, 800, 600)
        super.init(
            contentRect: frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .ignoresCycle,
            .fullScreenAuxiliary,
            .canJoinAllApplications,
            .fullScreenDisallowsTiling
        ]
        
        level = .statusBar
        isMovable = false
        ignoresMouseEvents = true
        backgroundColor = .clear
        center()
        makeKeyAndOrderFront(nil)
        
        contentView?.wantsLayer = true
        setupWebView()
        contentView?.alphaValue = 0.001
        
        DispatchQueue.main.async { [weak self] in
            self?.setupLayerSharing()
        }
    }
    
    override var canBecomeKey: Bool {
        return false
    }
    
    override var canBecomeMain: Bool {
        return false
    }
    
    func updateSize(bounds: CGRect) {
        print("new size \(bounds)")
        // TODO: implement
    }
    
    func reloadDisplayedToken() {
        if let html = currentGeneratedToken?.html {
            webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    private func setupWebView() {
        let webViewFrame = NSRect(x: 0, y: 0, width: 1000, height: 1000)
        // TODO: setup like parent macos app
        let webView = WKWebView(frame: webViewFrame)
        webView.wantsLayer = true
        if let html = currentGeneratedToken?.html {
            webView.loadHTMLString(html, baseURL: nil)
        }
        self.contentView?.addSubview(webView)
        self.webView = webView
    }
    
}

extension RenderingSourceWindow {
    
    func setupLayerSharing() {
        let options: NSDictionary = [:]
        if let contextClass = NSClassFromString("CAContext") as? NSObject.Type,
           let contextInstance = contextClass.perform(Selector(("remoteContextWithOptions:")), with: options)?.takeUnretainedValue() {
            remoteContext = contextInstance
            
            if let layer = webView?.layer {
                remoteContext?.setValue(layer, forKey: "layer")
            }
            
            if let retrievedContextId = remoteContext?.value(forKey: "contextId") as? UInt32 {
                contextId = retrievedContextId
            }
        }
    }
    
    func getContextId() -> UInt32 {
        return contextId
    }
    
}
