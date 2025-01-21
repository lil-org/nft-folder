// ∅ 2025 lil org

import AVKit

class PipPlaceholderView: NSView {
    
    private var playerLayer: AVPlayerLayer?
    private var pipController: AVPictureInPictureController?
    private var currentPipToken: GeneratedToken?
    private var didSetupPlayer = false
    private var layerHost: AnyObject?
    
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
        pipController?.delegate = self
        
        player.addObserver(self, forKeyPath: "rate", options: [.new, .old], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if let newRate = change?[.newKey] as? Float {
                if newRate == 0 {
                    print("Player paused")
                } else {
                    print("Player playing")
                }
            }
        }
    }
    
    func handleTogglePip(generatedToken: GeneratedToken) {
        let isPipActive = pipController?.isPictureInPictureActive == true
        let sameToken = currentPipToken?.html == generatedToken.html
        currentPipToken = generatedToken
        
        if isPipActive {
            if sameToken {
                pipController?.stopPictureInPicture() // TODO: not sure if we want it like this on macos
            }
        } else {
            togglePip()
        }
    }
    
    private func togglePip(retryCount: Int = 0) {
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
    
}

extension PipPlaceholderView: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: any Error) {}
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        // TODO: restore big player from pip
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
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
        
        if let layerHostClass = NSClassFromString("CALayerHost") as? NSObject.Type, let contextId = sharedSourceWindow?.getContextId() {
            layerHost = layerHostClass.init()
            layerHost?.setValue(contextId, forKey: "contextId")
            if let castedLayerHost = layerHost as? CALayer {
                castedLayerHost.frame = containerView.bounds
                containerView.layer?.addSublayer(castedLayerHost)
            }
        }
        
        if let contentView = window.contentView {
            contentView.addSubview(containerView)
            NSLayoutConstraint.activate([
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            
            containerView.postsFrameChangedNotifications = true
            
            NotificationCenter.default.addObserver(forName: NSView.frameDidChangeNotification, object: containerView, queue: .main) { [weak containerView, weak self] _ in
                if let containerView = containerView, let layerHost = self?.layerHost as? CALayer {
                    let newBounds = containerView.bounds
                    layerHost.frame = containerView.bounds
                    sharedSourceWindow?.updateSize(size: newBounds.size)
                }
            }
        }
        
        window.orderFrontRegardless()
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        // TODO: manually clean up source window and webview
        // TODO: remove itself from system pip window
        NSApplication.shared.terminate(nil)
    }
    
}
