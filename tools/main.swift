// ∅ nft-folder 2024

import Cocoa

let fresh =
"""
"""

//prepareForSelection(fresh)

//bundleSelected(useCollectionImages: true)

//rebundleImages(onlyMissing: true, useCollectionImage: false)

//removeBundledItem(name: "")

var generativeProjects = [GenerativeProject]() // TODO: read from bundle

for p in generativeProjects {
    let html = createRandomTokenHtml(project: p)
    // TODO: save html
}

print("🟢 all done")

func createRandomTokenHtml(project: GenerativeProject) -> String {
    // TODO: fill in template data correctly
    let template =
"""
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>
    <meta charset="utf-8"/>
    <script>
        // TODO: insert p5js here if needed
    </script>
    <script>
    let tokenData = {
        "tokenId": "114000424",
        "hash": "0x710e58f1a85051eb392ff157f7118f46cb6313708e2202644c9b3e3278e8a517"
    }
    </script>
    <script>
        // TODO: insert project script here
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
