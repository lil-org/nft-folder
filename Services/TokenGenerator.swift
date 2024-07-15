// ∅ nft-folder 2024

import Foundation

struct TokenGenerator {
    
    private static let dirURL = SuggestedItemsService.bundle.url(forResource: "Generative", withExtension: nil)!
    
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
              let project = try? JSONDecoder().decode(GenerativeProject.self, from: data),
              var randomToken = project.tokens.randomElement(),
              let suggestedItem = SuggestedItemsService.allItems.first(where: { $0.id == project.id }) else { return nil }
        
        if randomToken.id == notTokenId, let another = project.tokens.randomElement() {
            randomToken = another
        }
        
        let html = RawHtmlGenerator.createHtml(project: project, token: randomToken)
        let name: String
        if let abId = suggestedItem.abId, randomToken.id.hasPrefix(abId) && randomToken.id != abId {
            let cleanId = randomToken.id.dropFirst(abId.count).drop(while: { $0 == "0" })
            name = suggestedItem.name + " #" + (cleanId.isEmpty ? "0" : cleanId)
        } else {
            name = suggestedItem.name + " #" + randomToken.id
        }
        
        let webURL = NftGallery.opensea.url(network: .mainnet, chain: .ethereum, collectionAddress: project.contractAddress, tokenId: randomToken.id)
        let token = GeneratedToken(fullCollectionId: project.id,
                                   id: randomToken.id,
                                   html: html,
                                   displayName: name,
                                   url: webURL,
                                   instructions: project.instructions,
                                   screensaver: project.screensaverUrl)
        return token
    }
    
}
