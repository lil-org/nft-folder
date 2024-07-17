// ∅ nft-folder 2024

import Cocoa
import SwiftUI

class LocalHtmlWindow: NSWindow {
    
    private var playerModel = PlayerModel()
    private var cursorHideTimer: Timer?
    private var mouseMoveEventMonitor: Any?
    private var navigationKeysEventMonitor: Any?
    private weak var titleLabel: NSTextField?

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
        
        // TODO: add extra constraints to prevent overlapping with buttons
        
        let titleLabel = NSTextField(labelWithString: playerModel.currentToken.displayName)
        titleLabel.font = NSFont.preferredFont(forTextStyle: .callout)
        titleLabel.textColor = .gray
        titleLabel.backgroundColor = .clear
        titleLabel.isBezeled = false
        titleLabel.isEditable = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleBarView.addSubview(titleLabel)
        self.titleLabel = titleLabel
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
        leftButton.isBordered = false
        leftButton.contentTintColor = .gray
        titleBarView.addSubview(leftButton)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            leftButton.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 54)
        ])
        
        let rightButton = NSButton(image: Images.forwardTitleBar, target: self, action: #selector(forwardButtonClicked))
        rightButton.isBordered = false
        rightButton.contentTintColor = .gray
        titleBarView.addSubview(rightButton)
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            rightButton.leadingAnchor.constraint(equalTo: leftButton.trailingAnchor, constant: 8)
        ])
        
        let nextCollectionButton = NSButton(image: Images.nextCollectionTitleBar, target: self, action: #selector(nextCollectionButtonClicked))
        nextCollectionButton.isBordered = false
        nextCollectionButton.contentTintColor = .gray
        titleBarView.addSubview(nextCollectionButton)
        nextCollectionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextCollectionButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            nextCollectionButton.trailingAnchor.constraint(equalTo: infoButton.leadingAnchor, constant: -8)
        ])
        
        navigationKeysEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if let keyCode = event.charactersIgnoringModifiers?.unicodeScalars.first?.value {
                switch keyCode {
                case 0x0D, 0x20:
                    self?.nextCollectionButtonClicked()
                    return nil
                case 0xF700, 0xF701, 0xF702, 0xF703:
                    switch keyCode {
                    case 0xF700, 0xF702:
                        self?.backButtonClicked()
                    case 0xF701, 0xF703:
                        self?.forwardButtonClicked()
                    default:
                        break
                    }
                    return nil
                default:
                    break
                }
            }
            return event
        }
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
    
    private func updateTitle() {
        titleLabel?.stringValue = playerModel.currentToken.displayName
    }
    
    @objc private func nextCollectionButtonClicked() {
        playerModel.changeCollection()
        updateTitle()
    }
    
    @objc private func forwardButtonClicked() {
        playerModel.goForward()
        updateTitle()
    }
    
    @objc private func backButtonClicked() {
        playerModel.goBack()
        updateTitle()
    }
    
    @objc private func infoButtonClicked() {
        // TODO: show info popup
    }
    
    deinit {
        if let monitor = mouseMoveEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        
        if let monitor = navigationKeysEventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
}
