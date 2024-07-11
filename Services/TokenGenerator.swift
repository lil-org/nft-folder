// ∅ nft-folder 2024

import Foundation

struct TokenGenerator {
    
    private static let dirURL = SuggestedItemsService.bundle.url(forResource: "Generative", withExtension: nil)!
    
    private static var libScriptsDict = [String: String]()
    
    private static let jsonsNames: Set<String> = {
        let fileManager = FileManager.default
        let fileURLs = (try? fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)) ?? []
        let fileNames = fileURLs.map { $0.lastPathComponent }
        return Set(fileNames)
    }()
    
    static func generateRandomToken(specificCollectionId: String?, notCollectionId: String?, notTokenId: String?) -> GeneratedToken? {
        var jsonName: String
        if let specificCollectionId = specificCollectionId {
            jsonName = specificCollectionId + ".json"
        } else {
            jsonName = jsonsNames.randomElement() ?? ""
            if jsonName == notCollectionId {
                jsonName = jsonsNames.randomElement() ?? ""
            }
        }
        
        let url = dirURL.appendingPathComponent(jsonName)
        guard let data = try? Data(contentsOf: url),
              let project = try? JSONDecoder().decode(GenerativeProject.self, from: data),
              var randomToken = project.tokens.randomElement(),
              let suggestedItem = SuggestedItemsService.allItems.first(where: { $0.id == project.id }) else { return nil }
        
        if randomToken.id == notTokenId, let another = project.tokens.randomElement() {
            randomToken = another
        }
        
        let html = createHtml(project: project, token: randomToken)
        let name: String
        if let abId = suggestedItem.abId, randomToken.id.hasPrefix(abId) && randomToken.id != abId {
            let cleanId = randomToken.id.dropFirst(abId.count).drop(while: { $0 == "0" })
            name = suggestedItem.name + " #" + (cleanId.isEmpty ? "0" : cleanId)
        } else {
            name = suggestedItem.name + " #" + randomToken.id
        }
        
        let webURL = NftGallery.opensea.url(network: .mainnet, chain: .ethereum, collectionAddress: project.contractAddress, tokenId: randomToken.id)
        let token = GeneratedToken(fullCollectionId: project.id, id: randomToken.id, html: html, displayName: name, url: webURL, instructions: project.instructions)
        return token
    }
    
    private static func libScript(_ kind: GenerativeProject.Kind) -> String {
        if let libScript = libScriptsDict[kind.rawValue] {
            return libScript
        } else {
            guard let url = SuggestedItemsService.bundle.url(forResource: kind.rawValue, withExtension: "js"),
                  let libScript = try? String(contentsOf: url) else { return "" }
            libScriptsDict[kind.rawValue] = libScript
            return libScript
        }
    }
    
    private static func createHtml(project: GenerativeProject, token: GenerativeProject.Token) -> String {
        let script = project.script
        let libScript = libScript(project.kind)
        
        let tokenData: String
        if project.contractAddress == "0x059edd72cd353df5106d2b9cc5ab83a52287ac3a" {
            tokenData =
                """
                let tokenData = {"tokenId": "\(token.id)", "hashes": ["\(token.hash)"]}
                """
        } else {
            tokenData =
                """
                let tokenData = {"tokenId": "\(token.id)", "hash": "\(token.hash)"}
                """
        }
        
        let viewport =
            """
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>
            """
        
        let html: String
        switch project.kind {
        case .svg:
            html =
            """
            <html>
            <head>
              \(viewport)
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
            <script>\(script)</script>
            </html>
            """
        case .js:
            html =
            """
            <html>
            <head>
              \(viewport)
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
              <script>\(script)</script>
            </body>
            </html>
            """
        case .p5js100:
            html =
            """
            <html>
            <head>
              \(viewport)
              <meta charset="utf-8">
              <script>\(libScript)</script>
              <script>\(tokenData)</script>
              <script>\(script)</script>
              <style type="text/css">
                html {
                  height: 100%;
                }
                body {
                  min-height: 100%;
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
        case .paper:
            html =
            """
            <html>
            <head>
                \(viewport)
                <meta charset="utf-8"/>
                <script>\(libScript)</script>
                <script>\(tokenData)</script>
                <script>\(script)</script>
                    <style type="text/css">
                    html {
                        height: 100%;
                    }

                    body {
                        min-height: 100%;
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
        case .three:
            html =
            """
            <html>
              <head>
                \(viewport)
                <script>\(libScript)</script>
                <meta charset="utf-8">
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
              <body></body>
              <script>\(tokenData)</script>
              <script>\(script)</script>
            </html>
            """
        case .twemoji:
            html =
            """
            <html>
            <head>
                \(viewport)
                <meta charset="utf-8"/>
                <script>\(libScript)</script>
                <script>\(tokenData)</script>
                <script>\(script)</script>
                <style type="text/css">
                    html {
                        height: 100%;
                    }

                    body {
                        min-height: 100%;
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
        case .regl:
            html =
            """
            <html>
              <head>
                \(viewport)
                <script>\(libScript)</script>
                <script>\(tokenData)</script>
                <meta charset="utf-8">
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
                <script>\(script)</script>
              </body>
            </html>
            """
        case .tone:
            html =
            """
            <html>
              <head>
                \(viewport)
                <script>\(libScript)</script>
                <meta charset="utf-8">
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
              </body>
              <script>\(tokenData)</script>
              <script>\(script)</script>
            </html>
            """
        }
        return html
    }
    
}
