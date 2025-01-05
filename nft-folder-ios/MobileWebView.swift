// ∅ 2025 lil org

import SwiftUI
import WebKit
import AVKit

struct MobileWebView: UIViewRepresentable {
    let htmlString: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.suppressesIncrementalRendering = true
        let wkWebView = PipWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.setupPlayer()
        wkWebView.isOpaque = false
        wkWebView.backgroundColor = .black
        wkWebView.scrollView.backgroundColor = .black
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        wkWebView.configuration.userContentController.addUserScript(WKUserScript(source: "document.addEventListener('contextmenu', function(e) { e.preventDefault(); }, false);", injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        return wkWebView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}

// based on https://github.com/CaiWanFeng/PiP
class PipWebView: WKWebView {
    
    private var playerLayer: AVPlayerLayer!
    var pipController: AVPictureInPictureController!
    
    private var currentHtmlString: String?
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTogglePip(_:)), name: NSNotification.Name("togglePip"), object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func handleTogglePip(_ notification: Notification) {
        if let htmlString = notification.object as? String {
            currentHtmlString = htmlString
        }
        togglePip()
    }
    
    func togglePip() {
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
        }
    }
    
    func createNewCustomPipView() -> UIView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.suppressesIncrementalRendering = true
        let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
        wkWebView.isOpaque = false
        wkWebView.backgroundColor = .black
        wkWebView.scrollView.backgroundColor = .black
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        wkWebView.configuration.userContentController.addUserScript(WKUserScript(source: "document.addEventListener('contextmenu', function(e) { e.preventDefault(); }, false);", injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        if let htmlString = currentHtmlString {
            wkWebView.loadHTMLString(htmlString, baseURL: nil)
        }
        return wkWebView
    }
    
    func setupPlayer() {
        try? AVAudioSession.sharedInstance().setCategory(.playback)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        
        playerLayer = AVPlayerLayer()
        playerLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        let mp4Video = Bundle.main.url(forResource: "video", withExtension: "mp4")!
        let asset = AVAsset(url: mp4Video)
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer(playerItem: playerItem)
        playerLayer.player = player
        player.isMuted = true
        player.allowsExternalPlayback = true
        
        layer.addSublayer(playerLayer)
        
        pipController = AVPictureInPictureController(playerLayer: playerLayer)!
        pipController.delegate = self
        pipController.setValue(1, forKey: "controlsStyle")
    }
    
}

extension PipWebView: AVPictureInPictureControllerDelegate {
    
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
