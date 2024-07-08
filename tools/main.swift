// ∅ nft-folder 2024

import Cocoa

let fresh =
"""
"""

//prepareForSelection(fresh)

//bundleSelected(useCollectionImages: true)

//rebundleImages(onlyMissing: true, useCollectionImage: false)

//removeBundledItem(name: "")

struct ScriptJson: Codable {
    // let animationLengthInSeconds: Int?
    let type: String?
    // let animationLength: Int?
    let version: String?
    let license: String?
    let instructions: String?
    // let interactive: Bool?
    // let aspectRatio: String?
}

struct GenerativeProject: Codable {
    let contractAddress: String
    let projectId: String
    let tokens: [Token]
    let script: String
    
    let scriptTypeAndVersion: String?
    let scriptTypeAndVersionOverride: String?
    let scriptJson: ScriptJson?
    
    enum CodingKeys: String, CodingKey {
        case scriptTypeAndVersionOverride = "script_type_and_version_override"
        case scriptJson = "script_json"
        case script = "script"
        case contractAddress = "contract_address"
        case tokens = "tokens"
        case scriptTypeAndVersion = "script_type_and_version"
        case projectId = "project_id"
    }
    
    struct Token: Codable {
        
        let id: String
        let hash: String
        
        enum CodingKeys: String, CodingKey {
            case id = "token_id"
            case hash
        }
        
    }
    
}

let url = URL(fileURLWithPath: dir + "/tools/ab.json")
let data = try! Data(contentsOf: url)
let json = (try! JSONSerialization.jsonObject(with: data) as! [String: Any])["data"] as! [String: Any]
let abp = json["projects_metadata"] as! [[String: Any]]
let abpData = try! JSONSerialization.data(withJSONObject: abp)

let genarativeProjects = try! JSONDecoder().decode([GenerativeProject].self, from: abpData)
print(genarativeProjects.count)

print("🟢 all done")
