// ∅ nft-folder 2024

import Foundation

struct TokenGenerator {
    
    private static let dirURL = SuggestedItemsService.bundle.url(forResource: "Scripts", withExtension: nil)!
    
    private static let jsonsNames: Set<String> = {
        let fileManager = FileManager.default
        let fileURLs = (try? fileManager.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: nil)) ?? []
#if os(macOS)
        let fileNames = fileURLs.map { $0.lastPathComponent }
#elseif os(visionOS)
        let tmpDisabledForVisionPro = Set([
            "0x0a1bbd57033f57e7b6743621b79fcb9eb2ce367650",
            "0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270250",
            "0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270356",
            "0x99a9b7c1116f9ceeb1652de04d5969cce509b069472",
            "0x0a1bbd57033f57e7b6743621b79fcb9eb2ce367667",
        ])
        let fileNames = fileURLs.compactMap { tmpDisabledForVisionPro.contains(String($0.lastPathComponent.dropLast(5))) ? nil : $0.lastPathComponent }
#elseif os(tvOS)
        let tmpDisabled = Set([
            "0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd27029",
            "0x64780ce53f6e966e18a22af13a2f97369580ec113",
            "0x99a9b7c1116f9ceeb1652de04d5969cce509b069472",
            "0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270356",
            "0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270250",
            "0x0a1bbd57033f57e7b6743621b79fcb9eb2ce367664",
        ])
        let fileNames = fileURLs.compactMap { tmpDisabled.contains(String($0.lastPathComponent.dropLast(5))) ? nil : $0.lastPathComponent }
#endif
        return Set(fileNames)
    }()
    
    static var allGenerativeSuggestedItems: [SuggestedItem] {
        return SuggestedItemsService.visibleItems.filter { jsonsNames.contains($0.id + ".json") }
    }
    
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
        let cleanId = (randomToken.id.hasPrefix(script.abId) && randomToken.id != script.abId) ? String(randomToken.id.dropFirst(script.abId.count).drop(while: { $0 == "0" })) : randomToken.id
        let name = script.name + " #" + (cleanId.isEmpty ? "0" : cleanId)
        
#if canImport(AppKit)
        let webURL = NftGallery.opensea.url(network: .mainnet, chain: .ethereum, collectionAddress: script.address, tokenId: randomToken.id)
#else
        let webURL = NftGallery.etherscan.url(network: .mainnet, chain: .ethereum, collectionAddress: script.address, tokenId: randomToken.id)
#endif
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
