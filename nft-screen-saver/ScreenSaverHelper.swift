// ∅ nft-folder 2024

import Foundation

@objc class ScreenSaverHelper: NSObject {
    
    @objc static func generateHtml() -> String {
        let forceLibScript = decodeFromBase64(libScript)
        guard let data = projectJsonString.data(using: .utf8),
              let project = try? JSONDecoder().decode(GenerativeProject.self, from: data),
              let token = project.tokens.randomElement() else { return randomColorHtml }
        let html = RawHtmlGenerator.createHtml(project: project, token: token, forceLibScript: forceLibScript)
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
