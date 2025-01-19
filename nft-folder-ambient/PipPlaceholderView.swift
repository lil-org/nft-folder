// ∅ 2025 lil org

import SwiftUI
import AVKit
import WebKit

struct PipPlaceholderOverlay: NSViewRepresentable {
    func makeNSView(context: Context) -> PipPlaceholderView {
        PipPlaceholderView(frame: .zero)
    }
    
    func updateNSView(_ nsView: PipPlaceholderView, context: Context) {}
}

class PipPlaceholderView: NSView {
    private var playerLayer: AVPlayerLayer?
    private var pipController: AVPictureInPictureController?
    private var currentPipToken: GeneratedToken?
    private var didSetupPlayer = false
    private weak var displayedWebView: WKWebView?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTogglePip(_:)), name: Notification.Name.togglePip, object: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupPlayer() {
        playerLayer = AVPlayerLayer()
        guard let mp4Video = Bundle.main.url(forResource: "square", withExtension: "mp4"),
              let playerLayer = playerLayer else { return }
        playerLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        playerLayer.isHidden = true
        
        let asset = AVAsset(url: mp4Video)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)
        player.isMuted = true
        
        layer?.addSublayer(playerLayer)
        playerLayer.player = player
        
        pipController = AVPictureInPictureController(playerLayer: playerLayer)
        pipController?.delegate = self
    }
    
    @objc private func handleTogglePip(_ notification: Notification) {
        print("habdle toggle pip")
        
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
        print("will toggle pip")
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
    
    private func createNewCustomPipView() -> NSView {
        // TODO: make auto reloading
        // TODO: reuse desktop webview initializer
        let webView = WKWebView()
        if let token = currentPipToken {
            webView.loadHTMLString(token.html, baseURL: nil)
        }
        displayedWebView = webView
        return webView
    }
    
    private func webViewForStatusBarPlayer() -> WKWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.suppressesIncrementalRendering = true
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.wantsLayer = true
        webView.layer?.backgroundColor = NSColor.clear.cgColor
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.setValue(true, forKey: "drawsTransparentBackground")
        return webView
    }
    
}

extension PipPlaceholderView: AVPictureInPictureControllerDelegate {
    
    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: any Error) {
        print("failedToStartPictureInPictureWithError", error)
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        guard let window = NSApplication.shared.windows.first else { return }
        let customPipView = createNewCustomPipView()
        window.contentView?.addSubview(customPipView)
        customPipView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customPipView.topAnchor.constraint(equalTo: window.contentView!.topAnchor),
            customPipView.bottomAnchor.constraint(equalTo: window.contentView!.bottomAnchor),
            customPipView.leadingAnchor.constraint(equalTo: window.contentView!.leadingAnchor),
            customPipView.trailingAnchor.constraint(equalTo: window.contentView!.trailingAnchor)
        ])
    }
    
    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP will stop.")
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        print("PiP stopped.")
    }
    
    // TODO: restore from pip
    
}
