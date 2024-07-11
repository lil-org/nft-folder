// ∅ nft-folder 2024

import Foundation

func wipHtml(type: ScriptType, project: ProjectMetadata, token: Token) -> String {
    let script = project.script!
    
    let tokenData: String
    if project.contractAddress == "0x059edd72cd353df5106d2b9cc5ab83a52287ac3a" {
        tokenData =
            """
            let tokenData = {"tokenId": "\(token.tokenId)", "hashes": ["\(token.hash)"]}
            """
    } else {
        tokenData =
            """
            let tokenData = {"tokenId": "\(token.tokenId)", "hash": "\(token.hash)"}
            """
    }
    
    let html: String
    switch type {
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
        <script>\(script)</script>
        </html>
        """
    case .js:
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
          <script>\(script)</script>
        </body>
        </html>
        """
    case .p5js100, .p5js190:
        html =
        """
        <html>
        <head>
          <meta charset="utf-8">
          <script>\(type.libScript)</script>
          <script>\(tokenData)</script>
          <script>\(script)</script>
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
    case .processing:
        html =
        """
        <html>
          <head>
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
            <script>\(type.libScript)</script>
            <script>\(tokenData)</script>
            <script type="application/processing">\(script)</script>
            <canvas></canvas>
          </body>
        </html>
        """
    case .paper:
        html =
        """
        
        """
    case .babylon:
        html =
        """
        <html>
          <head>
            <script>\(tokenData)</script>
            <script>\(type.libScript)</script>
            <meta charset="utf-8">
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
          <body>
            <canvas id="babylon-canvas"></canvas>
          </body>
          <script>\(script)</script>
        </html>
        """
    case .three:
        html =
        """
        <html>
          <head>
            <script>\(type.libScript)</script>
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
        
        """
    case .regl:
        html =
        """
        <html>
          <head>
            <script>\(type.libScript)</script>
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
    case .zdog:
        html =
        """
        
        """
    case .tone:
        html =
        """
        <html>
          <head>
            <script>\(type.libScript)</script>
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
