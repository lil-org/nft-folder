// ∅ nft-folder 2024

import Foundation

struct RawHtmlGenerator {
    
    private static var libScriptsDict = [String: String]()
    
    private static func libScript(_ kind: Script.Kind) -> String {
        if let libScript = libScriptsDict[kind.rawValue] {
            return libScript
        } else {
            guard let url = Bundle.main.url(forResource: kind.rawValue, withExtension: "js"),
                  let libScript = try? String(contentsOf: url) else { return "" }
            libScriptsDict[kind.rawValue] = libScript
            return libScript
        }
    }
    
    static func createHtml(script: Script, token: BundledTokens.Item, forceLibScript: String? = nil) -> String {
        guard let hash = token.hash else { return "" }
        
        let id = token.id
        let libScript = forceLibScript ?? libScript(script.kind)
        
        let tokenData: String
        if script.address == "0x059edd72cd353df5106d2b9cc5ab83a52287ac3a" {
            tokenData =
                """
                let tokenData = {"tokenId": "\(id)", "hashes": ["\(hash)"]}
                """
        } else {
            tokenData =
                """
                let tokenData = {"tokenId": "\(id)", "hash": "\(hash)"}
                """
        }
        
        let viewport =
            """
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>
            """
        
        let html: String
        switch script.kind {
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
            <script>\(script.value)</script>
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
              <script>\(script.value)</script>
            </body>
            </html>
            """
        case .p5js100, .p5js190:
            html =
            """
            <html>
            <head>
              \(viewport)
              <meta charset="utf-8">
              <script>\(libScript)</script>
              <script>\(tokenData)</script>
              <script>\(script.value)</script>
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
                <script>\(script.value)</script>
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
              <script>\(script.value)</script>
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
                <script>\(script.value)</script>
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
                <script>\(script.value)</script>
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
              <script>\(script.value)</script>
            </html>
            """
        }
        return html
    }
    
}
