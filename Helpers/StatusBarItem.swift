// ∅ nft-folder 2024

import Cocoa
import SwiftUI

class StatusBarItem: NSObject, NSPopoverDelegate {
    
    static let shared = StatusBarItem()
    private override init() { super.init() }
    
    private let popover = NSPopover()
    private var statusBarItem: NSStatusItem?
    
    func showIfNeeded() {
        guard !Defaults.hideFromMenuBar else { return }
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusBarItem?.button?.image = Images.icon
        statusBarItem?.button?.imagePosition = .imageOnly
        statusBarItem?.button?.imageScaling = .scaleProportionallyDown
        statusBarItem?.button?.target = self
        statusBarItem?.button?.action = #selector(statusBarButtonClicked(sender:))
    }
    
    @objc private func statusBarButtonClicked(sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            showPopover()
        }
    }
    
    private func showPopover() {
        if let button = statusBarItem?.button {
            setupPopover()
            Window.closeAll()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            NSApp.activate(ignoringOtherApps: true)
            let popoverWindow = NSApplication.shared.windows.first(where: { $0.className.hasSuffix("PopoverWindow") })
            popoverWindow?.makeKeyAndOrderFront(nil)
        }
    }
    
    private func setupPopover() {
        let contentView = WalletsListView(showAddWalletPopup: false, inPopup: true)
        let viewController = NSHostingController(rootView: contentView)
        popover.behavior = .transient
        popover.contentSize = CGSize(width: 300, height: 482)
        popover.contentViewController = viewController
        popover.delegate = self
    }
    
    func popoverDidClose(_ notification: Notification) {
        popover.contentViewController = nil
    }
    
    @objc func hideFromMenuBar() {
        if let item = statusBarItem {
            NSStatusBar.system.removeStatusItem(item)
        }
    }
    
}
