// ∅ 2025 lil org

import Cocoa

class PipPlaceholderViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.green.cgColor
        
        let pipView = PipPlaceholderView(frame: view.bounds)
        pipView.autoresizingMask = [.width, .height]
        view.addSubview(pipView)
    }
}
