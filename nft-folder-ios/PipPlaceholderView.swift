// ∅ 2025 lil org
//
// based on PiP by @CaiWanFeng
//
// https://github.com/CaiWanFeng/PiP

import SwiftUI
import AVKit
import WebKit

struct PipPlaceholderOverlay: UIViewRepresentable {
    func makeUIView(context: Context) -> PipPlaceholderView {
        return PipPlaceholderView(frame: .zero)
    }
    
    func updateUIView(_ uiView: PipPlaceholderView, context: Context) {}
}

class PipPlaceholderView: UIView {
    
    private var playerLayer: AVPlayerLayer?
    private var pipController: AVPictureInPictureController?
    private var currentPipToken: GeneratedToken?
    private var didSetupPlayer = false
    
    private weak var displayedWebView: WKWebView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTogglePip(_:)), name: Notification.Name.togglePip, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupPlayer() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        playerLayer = AVPlayerLayer()
        
        guard let mp4Video = Bundle.main.url(forResource: "square", withExtension: "mp4"),
              let playerLayer = playerLayer else { return }
        
        playerLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        playerLayer.isHidden = true
        
        let asset = AVAsset(url: mp4Video)
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        player.isMuted = true
        player.allowsExternalPlayback = true
        
        layer.addSublayer(playerLayer)
        
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.delegate = self
        pipController?.setValue(1, forKey: "controlsStyle")
    }
    
    @objc private func handleTogglePip(_ notification: Notification) {
        guard let generatedToken = notification.object as? GeneratedToken else { return }
        
        let isPipActive = pipController?.isPictureInPictureActive == true
        let sameToken = currentPipToken?.html == generatedToken.html
        
        currentPipToken = generatedToken
        
        if isPipActive {
            if sameToken {
                pipController?.stopPictureInPicture()
            } else {
                displayedWebView?.loadHTMLString(generatedToken.html, baseURL: nil)
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
    
    private func createNewCustomPipView() -> UIView {
        let webView = AutoReloadingWebView.new
        if let token = currentPipToken {
            webView.loadHTMLString(token.html, baseURL: nil)
        }
        displayedWebView = webView
        return webView
    }
    
}

extension PipPlaceholderView: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        guard let window = (UIApplication.shared.value(forKey: "windows") as? [UIWindow])?.first else { return }
        let customPipView = createNewCustomPipView()
        window.addSubview(customPipView)
        customPipView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customPipView.topAnchor.constraint(equalTo: window.topAnchor),
            customPipView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            customPipView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            customPipView.trailingAnchor.constraint(equalTo: window.trailingAnchor)
        ])
    }
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: any Error) {}
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {}
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        NotificationCenter.default.post(name: Notification.Name.restoreMinimizedPip, object: currentPipToken)
        completionHandler(true)
    }
    
}
