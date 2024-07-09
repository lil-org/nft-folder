// ∅ nft-folder 2024

import Foundation

struct TokenGenerator {
    
    private static let dirURL = SuggestedItemsService.bundle.url(forResource: "Generative", withExtension: nil)!
    
    private static let p5js: String = {
        guard let url = SuggestedItemsService.bundle.url(forResource: "p5.min", withExtension: "js") else { return "" }
        return (try? String(contentsOf: url)) ?? ""
    }()
    
    private static let jsonsNames: Set<String> = {
        let fileManager = FileManager.default
        let fileURLs = (try? fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)) ?? []
        let fileNames = fileURLs.map { $0.lastPathComponent }
        return Set(fileNames)
    }()
    
    static func generateRandomToken() -> GeneratedToken? {
        guard let jsonName = jsonsNames.randomElement() else { return nil }
        let url = dirURL.appendingPathComponent(jsonName)
        guard let data = try? Data(contentsOf: url),
              let project = try? JSONDecoder().decode(GenerativeProject.self, from: data),
              let randomToken = project.tokens.randomElement(),
              let suggestedItem = SuggestedItemsService.allItems.first(where: { $0.id == project.id }) else { return nil }
        let html = createHtml(project: project, token: randomToken)
        let name: String
        if let abId = suggestedItem.abId, randomToken.id.hasPrefix(abId) && randomToken.id != abId {
            name = suggestedItem.name + " #" + randomToken.id.dropFirst(abId.count).drop(while: { $0 == "0" })
        } else {
            name = suggestedItem.name + " #" + randomToken.id
        }
        
        let webURL = NftGallery.opensea.url(network: .mainnet, chain: .ethereum, collectionAddress: project.contractAddress, tokenId: randomToken.id)
        let token = GeneratedToken(html: html, displayName: name, url: webURL, instructions: project.instructions)
        return token
    }
    
    private static func createHtml(project: GenerativeProject, token: GenerativeProject.Token) -> String {
        let tokenData =
        """
        let tokenData = {"tokenId": "\(token.id)", "hash": "\(token.hash)"}
        """
        
        let html: String
        switch project.kind {
        case .svg:
            html =
            """
            <html>
            <head>
              <meta charset="utf-8">
              <style type="text/css">
                body {
                  min-height: 100%;
                  margin: 0;
                  padding: 0;
                }
                svg {
                  padding: 0;
                  margin: auto;
                  display: block;
                  position: absolute;
                  top: 0;
                  bottom: 0;
                  left: 0;
                  right: 0;
                }
              </style>
            </head>
            <body></body>
            <script>\(tokenData)</script>
            <script>\(project.script)</script>
            </html>
            """
        case .js, .custom:
            html =
            """
            <html>
            <head>
              <meta charset="utf-8">
              <script>\(tokenData)</script>
              <style type="text/css">
                body {
                  margin: 0;
                  padding: 0;
                }
                canvas {
                  padding: 0;
                  margin: auto;
                  display: block;
                  position: absolute;
                  top: 0;
                  bottom: 0;
                  left: 0;
                  right: 0;
                }
              </style>
            </head>
            <body>
              <canvas></canvas>
              <script>\(project.script)</script>
            </body>
            </html>
            """
        case .p5js:
            html =
            """
            <html>
            <head>
              <meta charset="utf-8">
              <script>\(p5js)</script>
              <script>\(tokenData)</script>
              <script>\(project.script)</script>
              <style type="text/css">
                body {
                  margin: 0;
                  padding: 0;
                }
                canvas {
                  padding: 0;
                  margin: auto;
                  display: block;
                  position: absolute;
                  top: 0;
                  bottom: 0;
                  left: 0;
                  right: 0;
                }
              </style>
            </head>
            </html>
            """
        }
        return html
    }
    
}
