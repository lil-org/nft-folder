// ∅ 2025 lil org
//
// based on PiP by @CaiWanFeng
//
// https://github.com/CaiWanFeng/PiP

import SwiftUI
import AVKit

struct PipPlaceholderOverlay: UIViewRepresentable {
    func makeUIView(context: Context) -> PipPlaceholderView {
        return PipPlaceholderView(frame: .zero)
    }
    
    func updateUIView(_ uiView: PipPlaceholderView, context: Context) {}
}

class PipPlaceholderView: UIView {
    
    private var playerLayer: AVPlayerLayer?
    private var pipController: AVPictureInPictureController?
    
    private var currentHtmlString: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTogglePip(_:)), name: NSNotification.Name("togglePip"), object: nil)
        setupPlayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupPlayer() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        playerLayer = AVPlayerLayer()
        
        guard let mp4Video = Bundle.main.url(forResource: "videoH", withExtension: "mp4"),
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
        if let htmlString = notification.object as? String {
            currentHtmlString = htmlString
        }
        togglePip()
    }
    
    private func togglePip() {
        if pipController?.isPictureInPictureActive == true {
            pipController?.stopPictureInPicture()
        } else {
            pipController?.startPictureInPicture()
        }
    }
    
    private func createNewCustomPipView() -> UIView {
        let webView = MobileWebView.makeNewWebView()
        if let htmlString = currentHtmlString {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
        return webView
    }
    
}

extension PipPlaceholderView: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        guard let window = UIApplication.shared.windows.first else { return }
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
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        
    }
}
