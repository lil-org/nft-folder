// ∅ nft-folder 2024

import Cocoa
import SwiftUI

class LocalHtmlWindow: NSWindow {
    
    private var playerModel = PlayerModel()
    private var cursorHideTimer: Timer?
    private var mouseMoveEventMonitor: Any?

    private var isFullScreenOnActiveSpace: Bool {
        return styleMask.contains(.fullScreen) && isOnActiveSpace
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        
        let htmlView = LocalHtmlView(playerModel: playerModel, windowNumber: windowNumber).background(.black)
        self.contentView = NSHostingView(rootView: htmlView.frame(minWidth: 251, minHeight: 130))
        
        if NSScreen.screens.count <= 1 {
            mouseMoveEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseUp, .rightMouseUp, .mouseEntered]) { [weak self] event in
                self?.resetCursorHideTimer()
                return event
            }
        }
        
        setupTitleBar()
    }
    
    private func setupTitleBar() {
        guard let closeButton = standardWindowButton(.closeButton), let titleBarView = closeButton.superview else { return }
        
        titleBarView.wantsLayer = true
        titleBarView.layer?.backgroundColor = .black
        
        // TODO: use actual title
        // TODO: add extra constraints to prevent overlapping with buttons
        
        let titleLabel = NSTextField(labelWithString: "")
        titleLabel.font = NSFont.preferredFont(forTextStyle: .callout)
        titleLabel.textColor = .gray
        titleLabel.backgroundColor = .clear
        titleLabel.isBezeled = false
        titleLabel.isEditable = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleBarView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: titleBarView.centerXAnchor)
        ])
        
        let infoButton = NSButton(image: Images.infoTitleBar, target: self, action: #selector(infoButtonClicked))
        infoButton.keyEquivalent = "i"
        infoButton.isBordered = false
        infoButton.contentTintColor = .gray
        titleBarView.addSubview(infoButton)
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            infoButton.trailingAnchor.constraint(equalTo: titleBarView.trailingAnchor, constant: -8)
        ])
        
        let leftButton = NSButton(image: Images.backTitleBar, target: self, action: #selector(backButtonClicked))
        leftButton.keyEquivalent = String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!))
        leftButton.isBordered = false
        leftButton.contentTintColor = .gray
        titleBarView.addSubview(leftButton)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            leftButton.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 54)
        ])
        
        let rightButton = NSButton(image: Images.forwardTitleBar, target: self, action: #selector(forwardButtonClicked))
        rightButton.keyEquivalent = String(Character(UnicodeScalar(NSRightArrowFunctionKey)!))
        rightButton.isBordered = false
        rightButton.contentTintColor = .gray
        titleBarView.addSubview(rightButton)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            rightButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 8)
        ])
        
        let nextCollectionButton = NSButton(image: Images.nextCollectionTitleBar, target: self, action: #selector(nextCollectionButtonClicked))
        nextCollectionButton.keyEquivalent = "\r" // TODO: handle space as well
        nextCollectionButton.isBordered = false
        nextCollectionButton.contentTintColor = .gray
        titleBarView.addSubview(nextCollectionButton)
        nextCollectionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextCollectionButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            nextCollectionButton.leadingAnchor.constraint(equalTo: rightButton.trailingAnchor, constant: 8)
        ])
    }
    
    private func resetCursorHideTimer() {
        cursorHideTimer?.invalidate()
        if isFullScreenOnActiveSpace {
            cursorHideTimer = Timer.scheduledTimer(withTimeInterval: 2.3, repeats: false) { [weak self] _ in
                if self?.isFullScreenOnActiveSpace == true {
                    NSCursor.setHiddenUntilMouseMoves(true)
                }
            }
        }
    }
    
    @objc private func nextCollectionButtonClicked() {
        playerModel.changeCollection()
    }
    
    @objc private func forwardButtonClicked() {
        playerModel.goForward()
    }
    
    @objc private func backButtonClicked() {
        playerModel.goBack()
    }
    
    @objc private func infoButtonClicked() {
        // TODO: show info popup
    }
    
    deinit {
        if let monitor = mouseMoveEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
}
