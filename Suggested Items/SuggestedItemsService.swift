// ∅ nft-folder 2024

import Foundation

struct SuggestedItemsService {
    
    private static let bundle: Bundle = {
        if let bundleURL = Bundle.main.url(forResource: "Suggested", withExtension: "bundle"),
           let suggestedBundle = Bundle(url: bundleURL) {
            return suggestedBundle
        } else {
            return Bundle.main
        }
    }()
    
    static var allItems = readSuggestedItems()
    static var toHide = Set(Defaults.suggestedItemsToHide)
    
    static func doNotSuggestAnymore(item: SuggestedItem) {
        allItems.removeAll(where: { item.id == $0.id })
        toHide.insert(item.id)
        Defaults.suggestedItemsToHide = Array(toHide)
    }
    
    static func bundledTokens(collection: CollectionInfo, address: String) -> BundledTokens? {
        if let url = bundle.url(forResource: "Tokens/" + address, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let bundledTokens = try? JSONDecoder().decode(BundledTokens.self, from: data) {
            return bundledTokens
        } else {
            return nil
        }
    }
    
    private static func readSuggestedItems() -> [SuggestedItem] {
        guard let url = bundle.url(forResource: "items", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([SuggestedItem].self, from: data) else {
            return []
        }
        let filtered = items.filter { !toHide.contains($0.id) }
        return filtered
    }
    
}
