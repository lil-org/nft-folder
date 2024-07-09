// ∅ nft-folder 2024

import Cocoa

let fresh =
"""
"""

//prepareForSelection(fresh)

//bundleSelected(useCollectionImages: true)

//rebundleImages(onlyMissing: true, useCollectionImage: false)

//removeBundledItem(name: "")

let p5js = try! String(contentsOfFile: dir + "/tools/p5.min.js")
let generativeDirPath = dir + "/Suggested Items/Suggested.bundle/Generative/"
let generativeJsonsNames = try! FileManager.default.contentsOfDirectory(atPath: generativeDirPath)

for name in generativeJsonsNames {
    let data = try! Data(contentsOf: URL(filePath: generativeDirPath + name))
    let p = try! JSONDecoder().decode(GenerativeProject.self, from: data)
    let html = createRandomTokenHtml(project: p)
    try! html.write(toFile: selectedPath + p.id + ".html", atomically: true, encoding: .utf8)
    print("did generate \(p.id)")
}

print("🟢 all done")

func createRandomTokenHtml(project: GenerativeProject) -> String {
    let token = project.tokens.randomElement()!
    let libScript = project.kind == .p5js ? "\n<script>\(p5js)</script>\n" : ""
    let template =
"""
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>
    <meta charset="utf-8"/>\(libScript)
    <script>
    let tokenData = {
        "tokenId": "\(token.id)",
        "hash": "\(token.hash)"
    }
    </script>
    <script>
        console.log("https://generator.artblocks.io/\(project.contractAddress)/\(token.id)");
    </script>
    <script>
        \(project.script)
    </script>
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
    return template
}
