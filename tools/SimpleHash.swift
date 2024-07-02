// ∅ nft-folder 2024

import Foundation

struct SimpleHash {
    
    private init() {}
    
    private static let apiKey: String = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        let url = home.appending(path: "Developer/secrets/tools/SIMPLEHASH_API_KEY")
        let data = try! Data(contentsOf: url)
        return String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
    }()
    
    struct NftsResponse: Codable {
        let next: String?
        let nfts: [NFT]
    }
    
    struct CollectionsResponse: Codable {
        let next: String?
        let collections: [Collection]
    }
    
    struct NFT: Codable {
        let tokenId: String
        let name: String
        let imageUrl: String?
        let previews: Previews?
        
        enum CodingKeys: String, CodingKey {
            case tokenId = "token_id"
            case name, previews
            case imageUrl = "image_url"
        }
        
        struct Previews: Codable {
            let imageMediumUrl: String?
            let imageLargeUrl: String?
            let blurhash: String?
            let predominantColor: String?
            
            enum CodingKeys: String, CodingKey {
                case imageMediumUrl = "image_medium_url"
                case imageLargeUrl = "image_large_url"
                case blurhash
                case predominantColor = "predominant_color"
            }
        }
        
        var toBundle: BundledTokens.Item {
            return BundledTokens.Item(id: tokenId, name: name, url: imageUrl)
        }
    }
    
    struct Collection: Codable {
        let name: String
        let collectionId: String
        
        enum CodingKeys: String, CodingKey {
            case collectionId = "collection_id"
            case name
        }
    }
    
    static func previewCollections(input: String) {
        let contractAddresses = input.split(separator: "\n").map { String($0) }
        process(contractAddresses: contractAddresses)
        semaphore.wait()
    }
    
    private static func process(contractAddresses: [String]) {
        if let address = contractAddresses.first {
            getAllCollections(contractAddress: String(address), next: nil, addTo: []) { collections in
                save(contract: address, collections: collections)
                process(contractAddresses: Array(contractAddresses.dropFirst()))
            }
        } else {
            semaphore.signal()
        }
    }
    
    private static func save(contract: String, collections: [Collection]) {
        for collection in collections {
            let dirPath = selectedPath + contract + collection.collectionId
            try! FileManager.default.createDirectory(atPath: dirPath, withIntermediateDirectories: true)
            let project = ProjectToBundle(name: collection.name, tokens: [], contractAddress: contract, projectId: collection.collectionId)
            let data = try! encoder.encode(project)
            try! data.write(to: URL(filePath: dirPath + "/" + "project.json"))
        }
    }
    
    private static func getAllCollections(contractAddress: String, next: String?, addTo: [Collection], completion: @escaping ([Collection]) -> Void) {
        let url = URL(string: next ?? "https://api.simplehash.com/api/v0/nfts/collections/ethereum/\(contractAddress)?limit=50")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "X-API-KEY": apiKey
        ]
        let dataTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            let collectionsResponse = try! JSONDecoder().decode(CollectionsResponse.self, from: data!)
            if let next = collectionsResponse.next {
                getAllCollections(contractAddress: contractAddress, next: next, addTo: addTo + collectionsResponse.collections, completion: completion)
            } else {
                completion(addTo + collectionsResponse.collections)
            }
        }
        dataTask.resume()
    }
    
    static func getAllNfts(collectionId: String, next: String?, addTo: [NFT], completion: @escaping ([NFT]) -> Void) {
        getNfts(collectionId: collectionId, next: next, count: 50) { response in
            if let next = response.next {
                getAllNfts(collectionId: collectionId, next: next, addTo: addTo + response.nfts, completion: completion)
            } else {
                completion(addTo + response.nfts)
            }
        }
    }
    
    static func previewNfts(collectionId: String, completion: @escaping ([NFT]) -> Void) {
        getNfts(collectionId: collectionId, next: nil, count: 7) { response in
            completion(response.nfts)
        }
    }
    
    static func getNfts(collectionId: String, next: String?, count: Int, completion: @escaping (NftsResponse) -> Void) {
        let url = URL(string: next ?? "https://api.simplehash.com/api/v0/nfts/collection/\(collectionId)?limit=\(count)&include_attribute_percentages=0&include_unit_price_eth_wei=0")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "X-API-KEY": apiKey
        ]
        let dataTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            let nftsResponse = try! JSONDecoder().decode(NftsResponse.self, from: data!)
            completion(nftsResponse)
        }
        dataTask.resume()
    }
    
}
