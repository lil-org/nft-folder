// ∅ nft-folder 2024

import Foundation

struct TokenGenerator {
    
    private static let dirURL = SuggestedItemsService.bundle.url(forResource: "Scripts", withExtension: nil)!
    
    private static let jsonsNames: Set<String> = {
        let fileManager = FileManager.default
        let fileURLs = (try? fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)) ?? []
        let fileNames = fileURLs.map { $0.lastPathComponent }
        return Set(fileNames)
    }()
    
    private static var currentPassSet = Set<String>()
    
    private static func nextRandomCollection() -> String {
        if currentPassSet.isEmpty {
            currentPassSet = jsonsNames
        }
        let next = currentPassSet.randomElement() ?? ""
        currentPassSet.remove(next)
        return next
    }
    
    static func generateRandomToken(specificCollectionId: String?, notTokenId: String?) -> GeneratedToken? {
        var jsonName: String
        if let specificCollectionId = specificCollectionId {
            jsonName = specificCollectionId + ".json"
        } else {
            jsonName = nextRandomCollection()
        }
        let id = String(jsonName.dropLast(5))
        let url = dirURL.appendingPathComponent(jsonName)
        guard let data = try? Data(contentsOf: url),
              let script = try? JSONDecoder().decode(Script.self, from: data),
              let tokens = SuggestedItemsService.bundledTokens(collectionId: id)?.items,
              var randomToken = tokens.randomElement(),
              let suggestedItem = SuggestedItemsService.allItems.first(where: { $0.id == id }) else { return nil }
        
        if randomToken.id == notTokenId, let another = tokens.randomElement() {
            randomToken = another
        }
        
        let html = RawHtmlGenerator.createHtml(script: script, address: suggestedItem.address, token: randomToken)
        let name: String
        if let abId = suggestedItem.abId, randomToken.id.hasPrefix(abId) && randomToken.id != abId {
            let cleanId = randomToken.id.dropFirst(abId.count).drop(while: { $0 == "0" })
            name = suggestedItem.name + " #" + (cleanId.isEmpty ? "0" : cleanId)
        } else {
            name = suggestedItem.name + " #" + randomToken.id
        }
        
        let webURL = NftGallery.opensea.url(network: .mainnet, chain: .ethereum, collectionAddress: suggestedItem.address, tokenId: randomToken.id)
        let token = GeneratedToken(fullCollectionId: id,
                                   id: randomToken.id,
                                   html: html,
                                   displayName: name,
                                   url: webURL,
                                   instructions: script.instructions,
                                   screensaver: script.screensaverUrl)
        return token
    }
    
}
