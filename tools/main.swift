// ∅ nft-folder 2024

import Cocoa

let fresh: [(String, Chain)] = [
]

//prepareForSelection(input: fresh)

// TODO: make sure all bundled items have simplehash project id
// bundleSelected()

//rebundleImages(onlyMissing: true, useCollectionImage: true)




private func addCollectionIdForAllItems(index: Int) {
    if index == bundledSuggestedItems.count {
        let updatedSuggestedItemsData = try! encoder.encode(bundledSuggestedItems)
        try! updatedSuggestedItemsData.write(to: bundledSuggestedItemsUrl)
        semaphore.signal()
    } else {
        let item = bundledSuggestedItems[index]
        let data = try! Data(contentsOf: URL(fileURLWithPath: dir + "/Suggested Items/Suggested.bundle/Tokens/\(item.id).json"))
        let tokens = try! JSONDecoder().decode(BundledTokens.self, from: data)
        let tokenId = tokens.items.randomElement()!.id
        
        SimpleHash.getNft(chain: item.chain, tokenId: tokenId, contractAddress: item.address) { nft in
            let collectionId = nft.collection!.collectionId
            let updatedItem = SuggestedItem(name: item.name, address: item.address, chainId: item.chainId, chain: item.chain, collectionId: collectionId, projectId: item.projectId, hasVideo: item.hasVideo)
            bundledSuggestedItems[index] = updatedItem
            addCollectionIdForAllItems(index: index + 1)
        }
    }
}


addCollectionIdForAllItems(index: 0)
semaphore.wait()


print("🟢 all done")
