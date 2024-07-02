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
        let imageUrl: String
        
        enum CodingKeys: String, CodingKey {
            case tokenId = "token_id"
            case name
            case imageUrl = "image_url"
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
    
    static func getAllCollections(contractAddress: String) {
        // TODO: go through all
        let url = URL(string: "https://api.simplehash.com/api/v0/nfts/collections/ethereum/\(contractAddress)?limit=50")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "X-API-KEY": apiKey
        ]
        let dataTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            let collectionsResponse = try! JSONDecoder().decode(CollectionsResponse.self, from: data!)
            print(collectionsResponse)
            
            previewNfts(collectionId: collectionsResponse.collections.first!.collectionId, count: 5) // TODO: remove dev tmp
        }
        dataTask.resume()
        semaphore.wait()
    }
    
    static func previewNfts(collectionId: String, count: Int) {
        let url = URL(string: "https://api.simplehash.com/api/v0/nfts/collection/\(collectionId)?limit=\(count)&include_attribute_percentages=0&include_unit_price_eth_wei=0")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = [
          "accept": "application/json",
          "X-API-KEY": apiKey
        ]
        let dataTask = URLSession.shared.dataTask(with: request) { data, _, _ in
            let nftsResponse = try! JSONDecoder().decode(NftsResponse.self, from: data!)
            print(nftsResponse)
        }
        dataTask.resume()
    }
    
    static func getAllNfts(collectionId: String) {
        // TODO: go through all
        previewNfts(collectionId: collectionId, count: 50)
    }
    
}
