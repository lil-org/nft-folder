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
        
        let url = dirURL.appendingPathComponent(jsonName)
        guard let data = try? Data(contentsOf: url),
              let script = try? JSONDecoder().decode(Script.self, from: data),
              let tokens = SuggestedItemsService.bundledTokens(collectionId: script.id)?.items,
              var randomToken = tokens.randomElement() else { return nil }
        
        if randomToken.id == notTokenId, let another = tokens.randomElement() {
            randomToken = another
        }
        
        let html = RawHtmlGenerator.createHtml(script: script, token: randomToken)
        let cleanId = randomToken.id.dropFirst(script.abId.count).drop(while: { $0 == "0" })
        let name = script.name + " #" + (cleanId.isEmpty ? "0" : cleanId)
        
        let webURL = NftGallery.opensea.url(network: .mainnet, chain: .ethereum, collectionAddress: script.address, tokenId: randomToken.id)
        let token = GeneratedToken(fullCollectionId: script.id,
                                   id: randomToken.id,
                                   html: html,
                                   displayName: name,
                                   url: webURL,
                                   instructions: script.instructions,
                                   screensaver: script.screensaverUrl)
        return token
    }
    
}
