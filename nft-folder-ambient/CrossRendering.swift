import Cocoa
import QuartzCore
import WebKit

class SourceWindow: NSWindow {
    
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
        
        // TODO: tune in agent to make it always present
        //        collectionBehavior = [
        //                    .canJoinAllSpaces,  // Allows window across all spaces
        //                    .stationary,        // Prevents window from being moved by Mission Control
        //                    .fullScreenAuxiliary, // Allows overlaying on full-screen apps
        //                    .ignoresCycle       // Avoids cycling through Mission Control spaces
        //                ]
        
        collectionBehavior = [
            //                   .canJoinAllSpaces,      // Allow window to appear on all Spaces
            .fullScreenNone,        // Prevent it from entering fullscreen mode
            .moveToActiveSpace,     // Ensures it follows to the active space
            .transient, .fullScreenAuxiliary              // Makes it behave like a utility window (helps in fullscreen mode)
        ]
        
        level = .statusBar
        isMovable = false
        ignoresMouseEvents = true
        backgroundColor = .green // TODO: validate that it joins all spaces with .green
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
    
    func reloadDisplayedToken() {
        if let html = currentGeneratedToken?.html {
            webView?.loadHTMLString(html, baseURL: nil)
        }
    }
    
    private func setupWebView() {
        let webViewFrame = NSRect(x: 0, y: 0, width: 1000, height: 1000)
        let webView = WKWebView(frame: webViewFrame)
        webView.wantsLayer = true
        if let html = currentGeneratedToken?.html {
            webView.loadHTMLString(html, baseURL: nil)
        }
        self.contentView?.addSubview(webView)
        self.webView = webView
    }
    
}

extension SourceWindow {
    
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
