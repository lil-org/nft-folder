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
    
    static func bundledTokens(collection: CollectionInfo, address: String) -> BundledTokens? {
        // TODO: implement quick reading
        return nil
    }
    
    private static func readSuggestedItems() -> [SuggestedItem] {
        guard let url = Bundle.main.url(forResource: "suggested-items", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([SuggestedItem].self, from: data) else {
                return []
            }
        let filtered = items.filter { !toHide.contains($0.id) }
        return filtered
    }
    
}
