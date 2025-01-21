// ∅ 2025 lil org

import AVKit

class PipPlaceholderView: NSView {
    
    private var playerLayer: AVPlayerLayer?
    private var pipController: AVPictureInPictureController?
    private var didSetupPlayer = false
    private var layerHost: AnyObject?
    private var player: AVPlayer?
    private var lastPlayClickDate = Date.distantPast
    
    func handleTogglePip(generatedToken: GeneratedToken) {
        let isPipActive = pipController?.isPictureInPictureActive == true
        if !isPipActive {
            togglePip()
        }
    }
    
    private func didClickPlayButton() {
        // TODO: play next random item in collection
    }
    
    private func sendRestoreFromPipNotification() {
        guard let token = currentGeneratedToken,
              let data = try? JSONEncoder().encode(token),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        DistributedNotificationCenter.default().post(name: .restoreFromPip, object: jsonString)
    }
    
    private func setupPlayer() {
        playerLayer = AVPlayerLayer()
        guard let mp4Video = Bundle.main.url(forResource: "square", withExtension: "mp4"),
              let playerLayer = playerLayer else { return }
        playerLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        playerLayer.isHidden = true
        
        let asset = AVAsset(url: mp4Video)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        self.player = player
        player.isMuted = true
        player.allowsExternalPlayback = true
        layer?.addSublayer(playerLayer)
        playerLayer.player = player
        
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.delegate = self
        
        player.addObserver(self, forKeyPath: "rate", options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if let newRate = change?[.newKey] as? Float {
                if newRate == 1 && player?.status == .readyToPlay {
                    DispatchQueue.main.async { [weak self] in
                        self?.player?.pause()
                        guard let lastClickDate = self?.lastPlayClickDate else { return }
                        let nowDate = Date()
                        if nowDate.timeIntervalSince(lastClickDate) > 0.5 {
                            self?.lastPlayClickDate = nowDate
                        }
                    }
                }
            }
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
        if NSWorkspace.shared.runningApplications.contains(where: { $0.bundleIdentifier == "org.lil.nft-folder" }) {
            sendRestoreFromPipNotification()
            completionHandler(true)
        } else {
            NSWorkspace.shared.open(URL(string: "nft-folder://")!)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(230)) { [weak self] in
                self?.sendRestoreFromPipNotification()
                completionHandler(true)
            }
        }
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
        
        let prefix = "ca".uppercased()
        if let layerClass = NSClassFromString(prefix + Consts.layer.capitalized + Consts.host.capitalized) as? NSObject.Type,
           let contextId = sharedSourceWindow?.getContextId() {
            layerHost = layerClass.init()
            layerHost?.setValue(contextId, forKey: Consts.context + "i".uppercased() + "d")
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
        NSApplication.shared.terminate(nil)
    }
    
}
