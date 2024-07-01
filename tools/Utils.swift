// ∅ nft-folder 2024

import Foundation

struct Artblocks: Codable {
    let data: ArtblocksData
}

struct ArtblocksData: Codable {
    let projects: [Project]

    enum CodingKeys: String, CodingKey {
        case projects = "projects_metadata"
    }
}

struct Project: Codable {
    
    enum CurationStatus: String, Codable {
        case factory, curated, plyground
    }
    
    let projectId: String
    let contractAddress: String
    let curationStatus: CurationStatus
    let name: String
    let tokens: [Token]

    var allTokensHaveVideo: Bool {
        return !tokens.contains(where: { $0.videoId == nil })
    }
    
    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case contractAddress = "contract_address"
        case curationStatus = "curation_status"
        case name
        case tokens
    }
}

struct Token: Codable {
    let tokenId: String
    let videoId: Int?

    enum CodingKeys: String, CodingKey {
        case tokenId = "token_id"
        case videoId = "video_id"
    }
}

struct ArtblocksProjectToBundle {
    
    let name: String
    let hasVideo: Bool
    let tokens: [String]
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
