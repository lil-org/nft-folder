// ∅ nft-folder 2024

import Foundation

func processAbs() {
    let jsonNames = try! FileManager.default.contentsOfDirectory(atPath: wipPath + "abs/")
    for jsonName in jsonNames {
        let data = try! Data(contentsOf: URL(filePath: wipPath + "abs/" + jsonName))
        print(jsonName)
        let project = try! JSONDecoder().decode(ProjectMetadata.self, from: data)
    }
}

struct ProjectMetadata: Codable {
    let contractAddress: String
    let projectId: String
    let scriptTypeAndVersion: String?
    let scriptTypeAndVersionOverride: String?
    let script: String?
    let canvasMode: Bool?
    let aspectRatio: Double?
    let primaryRenderType: String?
    let displayStatic: Bool?
    let disableSampleGenerator: Bool?
    let disableAutoImageFormat: Bool?
    let previewRenderType: String?
    let renderComplete: Bool?
    let renderDelay: Int?
    let renderWithGpu: Bool?
    let artistName: String?
    let description: String?
    let id: String
    let invocations: Int
    let maxInvocations: Int
    let license: String?
    let tokens: [Token]
    let contract: Contract?
    let dependencyNameAndVersion: String?
    let generateVideoAssets: Bool?
    let scriptCount: Int?
    let scriptJson: ScriptJson?
    let scripts: [Script]
    let name: String?
    let externalAssetDependencyCount: Int?
    let creativeCredit: String?
    
    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case projectId = "project_id"
        case scriptTypeAndVersion = "script_type_and_version"
        case scriptTypeAndVersionOverride = "script_type_and_version_override"
        case script
        case canvasMode = "canvas_mode"
        case aspectRatio = "aspect_ratio"
        case primaryRenderType = "primary_render_type"
        case displayStatic = "display_static"
        case disableSampleGenerator = "disable_sample_generator"
        case disableAutoImageFormat = "disable_auto_image_format"
        case previewRenderType = "preview_render_type"
        case renderComplete = "render_complete"
        case renderDelay = "render_delay"
        case renderWithGpu = "render_with_gpu"
        case artistName = "artist_name"
        case description
        case id
        case invocations
        case maxInvocations = "max_invocations"
        case license
        case tokens
        case contract
        case dependencyNameAndVersion = "dependency_name_and_version"
        case generateVideoAssets = "generate_video_assets"
        case scriptCount = "script_count"
        case scriptJson = "script_json"
        case scripts
        case name
        case externalAssetDependencyCount = "external_asset_dependency_count"
        case creativeCredit = "creative_credit"
    }
}

struct Script: Codable {
    let script: String
}

struct ScriptJson: Codable {
    
    // TODO: add all keys
    
}

struct Token: Codable {
    let id: String
    let hash: String
    let tokenId: String
    let invocation: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case hash
        case tokenId = "token_id"
        case invocation
    }
}

struct Contract: Codable {
    let address: String
    let preferredArweaveGateway: String?
    let preferredIpfsGateway: String?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case preferredArweaveGateway = "preferred_arweave_gateway"
        case preferredIpfsGateway = "preferred_ipfs_gateway"
        case name
    }
}

func getAllArtBlocks() {
    let url = URL(string: "https://data.artblocks.io/v1/graphql")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let operationName = "abq"
    let query = """
      query abq {
        projects_metadata {
          contract_address
          project_id
          script_type_and_version
          script_type_and_version_override
          script
          canvas_mode
          aspect_ratio
          primary_render_type
          display_static
          disable_sample_generator
          disable_auto_image_format
          preview_render_type
          render_complete
          render_delay
          render_with_gpu
          artist_name
          description
          id
          invocations
          max_invocations
          license
          tokens {
            id
            hash
            token_id
            invocation
          }
          contract {
            address
            preferred_arweave_gateway
            preferred_ipfs_gateway
            name
          }
          dependency_name_and_version
          generate_video_assets
          script_count
          script_json
          scripts {
            script
          }
          name
          external_asset_dependency_count
          creative_credit
        }
      }
    """
    let variables = [String: Any]()
    let requestBody: [String : Any] = [
        "query": query,
        "variables": variables,
        "operationName": operationName
    ]

    let jsonData = try! JSONSerialization.data(withJSONObject: requestBody, options: [])
    request.httpBody = jsonData
    let task = URLSession.shared.dataTask(with: request) { data, _, _ in
        try! data!.write(to: URL(filePath: wipPath + "ab.json"))
        semaphore.signal()
    }
    task.resume()
    semaphore.wait()

}
