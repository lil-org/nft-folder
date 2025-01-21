// ∅ 2025 lil org

import AVKit
import WebKit

class PipPlaceholderView: NSView {
    
    private var playerLayer: AVPlayerLayer?
    private var pipController: AVPictureInPictureController?
    private var currentPipToken: GeneratedToken?
    private var didSetupPlayer = false
    private var displayedWebView: WKWebView?
    
    private var animationActivity: NSObjectProtocol?
    
    private func setupPlayer() {
        playerLayer = AVPlayerLayer()
        guard let mp4Video = Bundle.main.url(forResource: "square", withExtension: "mp4"),
              let playerLayer = playerLayer else { return }
        playerLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        playerLayer.isHidden = true
        
        let asset = AVAsset(url: mp4Video)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        
        
        
        player.isMuted = true
        player.allowsExternalPlayback = true
        
        layer?.addSublayer(playerLayer)
        playerLayer.player = player
        
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.requiresLinearPlayback = true
        pipController?.delegate = self
        pipController?.setValue(1, forKey: "controlsStyle")
    }
    
    func handleTogglePip(generatedToken: GeneratedToken) {
        NSLog("handleTogglePip")
        
        let isPipActive = pipController?.isPictureInPictureActive == true
        let sameToken = currentPipToken?.html == generatedToken.html
        currentPipToken = generatedToken
        
        if isPipActive {
            //            if sameToken {
            //                pipController?.stopPictureInPicture()
            //            } else {
            NSLog("will loadHTMLString")
            NSLog(displayedWebView.debugDescription)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                
                NSApplication.shared.activate(ignoringOtherApps: true)
                
                self?.displayedWebView?.loadHTMLString(generatedToken.html, baseURL: nil)
                
                
                NSLog("did load HTML")
            }
            //            }
        } else {
            togglePip()
        }
    }
    
    private func togglePip(retryCount: Int = 0) {
        print("will toggle pip")
        
        print("current windows are:")
        
        
        if !didSetupPlayer {
            setupPlayer()
            didSetupPlayer = true
        }
        guard let pipController = pipController else { return }
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        } else {
            if pipController.isPictureInPicturePossible {
                pipController.startPictureInPicture()
            } else if retryCount < 3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
                    self?.togglePip(retryCount: retryCount + 1)
                }
            }
        }
    }
    
    private func webViewForStatusBarPlayer() -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.suppressesIncrementalRendering = true
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.wantsLayer = true
        webView.layer?.backgroundColor = NSColor.clear.cgColor
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.setValue(true, forKey: "drawsTransparentBackground")
        webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        return webView
    }
    
    var layerHost: AnyObject?
    
}

extension PipPlaceholderView: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: any Error) {
        NSLog("failedToStartPictureInPictureWithError")
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        NSLog("pictureInPictureControllerDidStartPictureInPicture")
        
        guard let window = NSApplication.shared.windows.last else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.embedAnimatedWebView(in: window)
        }
    }
    
    func embedAnimatedWebView(in window: NSWindow) {
        if let contentView = window.contentView {
            contentView.wantsLayer = true
        }
        
        let containerView = NSView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.wantsLayer = true
        
        
        
        if let layerHostClass = NSClassFromString("CALayerHost") as? NSObject.Type, let contextId = sharedSourceWindow?.getContextID() {
            layerHost = layerHostClass.init()
            layerHost?.setValue(contextId, forKey: "contextId")
            
            if let castedLayerHost = layerHost as? CALayer {
                castedLayerHost.frame = containerView.bounds
                containerView.layer?.addSublayer(castedLayerHost)
                print("Renderer: Displaying remote layer with context ID \(contextId).")
            } else {
                print("Failed to cast CALayerHost.")
            }
        } else {
            print("Failed to create CALayerHost.")
        }
        
        
        if let contentView = window.contentView {
            contentView.addSubview(containerView)
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
        
        window.orderFrontRegardless()
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        NSLog("PiP will stop.")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // TODO: manually clean up source window and webview
        // TODO: remove itself from system pip window
        NSApplication.shared.terminate(nil)
    }
    
    // TODO: restore from pip
    
}
