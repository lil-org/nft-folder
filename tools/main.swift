// ∅ nft-folder 2024

import Cocoa

let ethCollections =
"""
"""

let fresh: [(String, Chain)] = ethCollections.split(separator: "\n").map { (String($0), .ethereum) }

//prepareForSelection(input: fresh)

//bundleSelected()

//rebundleImages(onlyMissing: true, useCollectionImage: true)

//removeBundledItems("")

print("🟢 all done")
