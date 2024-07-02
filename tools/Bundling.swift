// ∅ nft-folder 2024

import Foundation

struct ProjectToBundle: Codable {
    
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
