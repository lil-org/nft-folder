// ∅ 2025 lil org

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
        let disabledForTv = Set([
            "0x99a9b7c1116f9ceeb1652de04d5969cce509b069472",
            "0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270356",
            "0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270250",
            "0x0a1bbd57033f57e7b6743621b79fcb9eb2ce367664",
        ])
        let fileNames = fileURLs.compactMap { disabledForTv.contains(String($0.lastPathComponent.dropLast(5))) ? nil : $0.lastPathComponent }
#endif
        return Set(fileNames)
    }()
    
    static func canGenerate(id: String) -> Bool {
        return jsonsNames.contains(id + ".json")
    }
    
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
    
    static func generateRandomToken(specificCollectionId: String, specificInputTokenId: String) -> GeneratedToken? {
        guard !specificInputTokenId.isEmpty && !specificInputTokenId.contains(where: { $0.isLetter }) else { return nil }
        let url = dirURL.appendingPathComponent(specificCollectionId + ".json")
        guard let data = try? Data(contentsOf: url),
              let script = try? JSONDecoder().decode(Script.self, from: data),
              let tokens = SuggestedItemsService.bundledTokens(collectionId: script.id)?.items else { return nil }
        let cleanInput = specificInputTokenId.filter { $0.isNumber }
        if let target = tokens.first(where: { $0.id == cleanInput }) ?? tokens.first(where: { $0.id.hasSuffix("000" + cleanInput) }) {
            return generateToken(target, script: script)
        } else {
            return nil
        }
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
        
        return generateToken(randomToken, script: script)
    }
    
    private static func generateToken(_ token: BundledTokens.Item, script: Script) -> GeneratedToken? {
        let html = RawHtmlGenerator.createHtml(script: script, token: token)
        let cleanId = (token.id.hasPrefix(script.abId) && token.id != script.abId) ? String(token.id.dropFirst(script.abId.count).drop(while: { $0 == "0" })) : token.id
        let name = script.name + " #" + (cleanId.isEmpty ? "0" : cleanId)
        
#if canImport(AppKit)
        let webURL = NftGallery.opensea.url(network: .mainnet, chain: .ethereum, collectionAddress: script.address, tokenId: token.id)
#else
        let webURL = NftGallery.blockExplorer.url(network: .mainnet, chain: .ethereum, collectionAddress: script.address, tokenId: token.id)
#endif
        let generatedToken = GeneratedToken(fullCollectionId: script.id,
                                            address: script.address,
                                            id: token.id,
                                            html: html,
                                            displayName: name,
                                            url: webURL,
                                            instructions: script.instructions,
                                            screensaver: script.screensaverUrl)
        return generatedToken
    }
    
}
