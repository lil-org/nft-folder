// ∅ 2025 lil org

import Foundation

var alternativeResourcesPath: String?

struct SuggestedItemsService {
    
    static let bundle: Bundle = {
        if let altPath = alternativeResourcesPath,
           let altBundle = Bundle(url: URL(fileURLWithPath: altPath + "/Contents/Resources/Suggested.bundle")) {
            return altBundle
        } else if let bundleURL = Bundle.main.url(forResource: "Suggested", withExtension: "bundle"),
           let suggestedBundle = Bundle(url: bundleURL) {
            return suggestedBundle
        } else {
            return Bundle.main
        }
    }()
    
    static var allItems = [SuggestedItem]()
    static var visibleItems = readSuggestedItems()
    static var toHide = Set(Defaults.suggestedItemsToHide)
    
    static func doNotSuggestAnymore(item: SuggestedItem) {
        visibleItems.removeAll(where: { item.id == $0.id })
        toHide.insert(item.id)
        Defaults.suggestedItemsToHide = Array(toHide)
    }
    
    static func suggestedItems(address: String) -> [SuggestedItem] {
        let lowercased = address.lowercased()
        guard !address.hasSuffix(".eth") else { return [] }
        return allItems.filter { $0.address.lowercased() == lowercased }
    }
    
    static func bundledTokens(collectionId: String) -> BundledTokens? {
        if let url = bundle.url(forResource: "Tokens/" + collectionId, withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let bundledTokens = try? JSONDecoder().decode(BundledTokens.self, from: data) {
            return bundledTokens
        } else {
            return nil
        }
    }
    
    static func restoredSuggestedItems(usersWallets: [WatchOnlyWallet]) -> [SuggestedItem] {
        let walletsIds = Set(usersWallets.map { $0.id })
        let hiddenAndAddedByUser = Defaults.suggestedItemsToHide.filter { walletsIds.contains($0) }
        Defaults.suggestedItemsToHide = hiddenAndAddedByUser
        toHide = Set(hiddenAndAddedByUser)
        visibleItems = readSuggestedItems()
        return visibleItems
    }
    
    private static func readSuggestedItems() -> [SuggestedItem] {
        if allItems.isEmpty {
            guard let url = bundle.url(forResource: "items", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let items = try? JSONDecoder().decode([SuggestedItem].self, from: data) else {
                return []
            }
            allItems = items
        }
        
        let filtered = allItems.filter { !toHide.contains($0.id) }
        return filtered
    }
    
}
