// ∅ 2025 lil org

import Cocoa

class PipVideoSourceViewController: NSViewController {

    private weak var pipView: PipPlaceholderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.green.cgColor
        
        let pipView = PipPlaceholderView(frame: view.bounds)
        pipView.autoresizingMask = [.width, .height]
        view.addSubview(pipView)
        self.pipView = pipView
    }
    
    func didReceivePipNotificationWithToken(_ token: GeneratedToken) {
        pipView?.handleTogglePip(generatedToken: token)
    }
    
}
