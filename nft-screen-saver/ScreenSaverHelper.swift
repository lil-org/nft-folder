// ∅ 2025 lil org

import Foundation

@objc class ScreenSaverHelper: NSObject {
    
    @objc static func generateHtml() -> String {
        let forceLibScript = decodeFromBase64(libScript)
        guard let scriptData = scriptJsonString.data(using: .utf8),
              let script = try? JSONDecoder().decode(Script.self, from: scriptData),
              let tokensData = tokensJsonString.data(using: .utf8),
              let tokens = try? JSONDecoder().decode(BundledTokens.self, from: tokensData),
              let token = tokens.items.randomElement() else { return randomColorHtml }
        let html = RawHtmlGenerator.createHtml(script: script, address: address, token: token, forceLibScript: forceLibScript)
        return html
    }
    
    private static func decodeFromBase64(_ input: String) -> String {
        guard let data = Data(base64Encoded: input) else {
            return ""
        }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
}

private var randomColorHtml: String {
    let red = Int.random(in: 0...255)
    let green = Int.random(in: 0...255)
    let blue = Int.random(in: 0...255)
    let randomColor = String(format: "#%02X%02X%02X", red, green, blue)
    let html = """
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
    return html
}
