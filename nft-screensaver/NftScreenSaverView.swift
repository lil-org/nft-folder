// ∅ nft-folder 2024

import ScreenSaver
import WebKit

class NftScreenSaverView: ScreenSaverView {
    
    private var webView: WKWebView?
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setupWebView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupWebView()
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: bounds, configuration: webConfiguration)
        
        if let webView = webView {
            addSubview(webView)
            webView.autoresizingMask = [.width, .height]
            
            let randomColor = generateRandomColor()
            let htmlContent = """
            <html>
            <head>
                <style>
                    body {
                        margin: 0;
                        padding: 0;
                        width: 100vw;
                        height: 100vh;
                        background-color: \(randomColor);
                    }
                </style>
            </head>
            <body>
            </body>
            </html>
            """
            
            webView.loadHTMLString(htmlContent, baseURL: nil)
        }
    }
    
    private func generateRandomColor() -> String {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
