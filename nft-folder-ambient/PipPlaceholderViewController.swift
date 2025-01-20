// ∅ 2025 lil org

import Cocoa

class PipPlaceholderViewController: NSViewController {

    private weak var pipView: PipPlaceholderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.green.cgColor
        
        let pipView = PipPlaceholderView(frame: view.bounds)
        pipView.autoresizingMask = [.width, .height]
        view.addSubview(pipView)
        self.pipView = pipView
        
        NSLog("did add pip view")
    }
    
    func didReceivePipNotificationWithToken(_ token: GeneratedToken) {
        NSLog("will handle toggle pip")
        pipView?.handleTogglePip(generatedToken: token)
        NSLog("did handle toggle pip")
    }
    
}
