// ∅ nft-folder 2024

import Foundation

struct SuggestedItemsService {
    
    static var allItems = readSuggestedItems()
    static var toHide = Set(Defaults.suggestedItemsToHide)
    
    static func doNotSuggestAnymore(item: SuggestedItem) {
        allItems.removeAll(where: { item.id == $0.id })
        toHide.insert(item.id)
        Defaults.suggestedItemsToHide = Array(toHide)
    }
    
    private static func readSuggestedItems() -> [SuggestedItem] {
        let items = [
            SuggestedItem(name: "Allstarz Official", address: "0xec0a7a26456b8451aefc4b00393ce1beff5eb3e9", chainId: 1),
            SuggestedItem(name: "Pudgy Penguins", address: "0xbd3531da5cf5857e7cfaa92426877b022e612cf8", chainId: 1),
            SuggestedItem(name: "Creature World", address: "0xc92ceddfb8dd984a89fb494c376f9a48b999aafc", chainId: 1),
            SuggestedItem(name: "Peaceful Groupies", address: "0x4f89cd0cae1e54d98db6a80150a824a533502eea", chainId: 1),
            SuggestedItem(name: "Very Internet Person", address: "0xfed18c828277e3bd8610f9bae432e65a651706f7", chainId: 1)
        ]
        let filtered = items.filter { !toHide.contains($0.id) }
        return filtered
    }
    
}
