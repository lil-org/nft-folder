// ∅ nft-folder 2024

import Cocoa

let fresh: [(String, Chain)] = [
]

//prepareForSelection(input: fresh)

// TODO: make sure all bundled items have simplehash project id
// bundleSelected()

//rebundleImages(onlyMissing: true, useCollectionImage: true)

for item in bundledSuggestedItems {
    if item.collectionId == nil {
        print(item.name)
    }
}

print("🟢 all done")
