// ∅ nft-folder 2024

import Foundation

struct SimpleHashResponse: Codable {
    
    let next: String
    let nfts: [NFT]
    
    struct NFT: Codable {
        let tokenId: String
        let name: String
        let imageUrl: String
        
        enum CodingKeys: String, CodingKey {
            case tokenId = "token_id"
            case name = "name"
            case imageUrl = "image_url"
        }
    }
    
}

struct ProjectToBundle {
    
    let name: String
    let tokens: [BundledTokens.Item]
    let contractAddress: String
    let projectId: String
    
    var id: String {
        return contractAddress + projectId
    }
    
}

func imagesetContentsFileData(id: String) -> Data {
    let jsonString =
    """
    {
      "images" : [
        {
          "filename" : "\(id).jpeg",
          "idiom" : "universal"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    return jsonString.data(using: .utf8)!
}
