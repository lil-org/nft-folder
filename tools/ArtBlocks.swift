// ∅ nft-folder 2024

import Foundation

enum ScriptType: String, Codable, CaseIterable {
    case js, svg, processing, paper, babylon, p5js100, p5js190, three, twemoji, regl, zdog, tone
    
    var remoteUrl: String? {
        switch self {
        case .js, .svg:
            return nil
        case .processing:
            return "https://cdnjs.cloudflare.com/ajax/libs/processing.js/1.4.6/processing.min.js"
        case .paper:
            return "https://cdnjs.cloudflare.com/ajax/libs/paper.js/0.12.15/paper-full.min.js"
        case .babylon:
            return "https://cdnjs.cloudflare.com/ajax/libs/babylonjs/5.0.0/babylon.js"
        case .p5js100:
            return "https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.0.0/p5.min.js"
        case .p5js190:
            return "https://cdnjs.cloudflare.com/ajax/libs/p5.js/1.9.0/p5.min.js"
        case .three:
            return "https://cdnjs.cloudflare.com/ajax/libs/three.js/r124/three.min.js"
        case .twemoji:
            return "https://unpkg.com/twemoji@14.0.2/dist/twemoji.min.js"
        case .regl:
            return "https://cdnjs.cloudflare.com/ajax/libs/regl/2.1.0/regl.min.js"
        case .zdog:
            return "https://unpkg.com/zdog@1/dist/zdog.dist.min.js"
        case .tone:
            return "https://cdnjs.cloudflare.com/ajax/libs/tone/14.8.15/Tone.js"
        }
    }
    
    var localUrl: URL {
        return URL(filePath: wipPath + "libs/" + rawValue + ".js")
    }
    
    static func fromString(_ string: String) -> ScriptType? {
        switch string {
        case "processing-js@1.4.6":
            return .processing
        case "paper@0.12.15":
            return .paper
        case "custom@na", "js@n/a", "js@undefined", "js@", "js@na":
            return .js
        case "svg@na":
            return .svg
        case "babylon@5.0.0":
            return .babylon
        case "p5@1.9.0":
            return .p5js190
        case "three@0.124.0":
            return .three
        case "twemoji@14.0.2":
            return .twemoji
        case "p5@1.0.0":
            return .p5js100
        case "regl@2.1.0":
            return .regl
        case "zdog@1.1.2":
            return .zdog
        case "tone@14.8.15":
            return .tone
        default:
            return nil
        }
    }
    
    var libScript: String {
        if remoteUrl != nil {
            return try! String(contentsOf: localUrl)
        } else {
            return ""
        }
    }
    
}

func getAllLibs() {
    for scriptType in ScriptType.allCases {
        if let origin = scriptType.remoteUrl, let url = URL(string: origin) {
            let data = try! Data(contentsOf: url)
            try! data.write(to: scriptType.localUrl)
        }
    }
}

func processAbs() {
    getAllLibs()
    
//    let jsonNames = try! FileManager.default.contentsOfDirectory(atPath: wipPath + "abs/")
//    for jsonName in jsonNames {
//        let data = try! Data(contentsOf: URL(filePath: wipPath + "abs/" + jsonName))
//        let project = try! JSONDecoder().decode(ProjectMetadata.self, from: data)
//        
//        guard project.externalAssetDependencyCount == 0 &&
//                bundledSuggestedItems.contains(where: { $0.id == project.contractAddress + project.projectId })
//                && project.script != nil else { continue }
//        generateRandomToken(project: project)
//    }
}

func generateRandomToken(project: ProjectMetadata) {
    let type = ScriptType.fromString(project.scriptTypeAndVersion)!
    let html = wipHtml(type: type, project: project, token: project.tokens.randomElement()!)
    try! html.write(toFile: selectedPath + project.id + ".html", atomically: true, encoding: .utf8)
}

struct ProjectMetadata: Codable {
    let id: String
    
    let name: String
    let contractAddress: String
    let projectId: String
    
    let tokens: [Token]
    
    let scriptTypeAndVersion: String
    
    let script: String?
    let canvasMode: Bool
    let aspectRatio: Double
    let primaryRenderType: String
    let displayStatic: Bool
    let disableSampleGenerator: Bool
    let disableAutoImageFormat: Bool?
    let previewRenderType: String
    let renderComplete: Bool
    let renderDelay: Double
    let renderWithGpu: Bool
    
    let invocations: Int
    let maxInvocations: Int
    
    let contract: Contract?
    
    let scriptCount: Int
    let scriptJson: ScriptJson?
    let scripts: [Script]
    let generateVideoAssets: Bool
    
    let externalAssetDependencyCount: Int
    
    let artistName: String?
    let description: String?
    let creativeCredit: String?
    let license: String?
    
    enum CodingKeys: String, CodingKey {
        case contractAddress = "contract_address"
        case projectId = "project_id"
        case scriptTypeAndVersion = "script_type_and_version"
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
    let type: String
    let curationStatus: String?
    let license: String?
    let interactive: String?
    let version: String?
    let instructions: String?
    let animationLength: Double?
    let animationLengthInSeconds: Double?
    let aspectRatio: Double?

    enum CodingKeys: String, CodingKey {
        case type
        case curationStatus
        case license
        case interactive
        case version
        case instructions
        case animationLength
        case animationLengthInSeconds
        case aspectRatio
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        curationStatus = try container.decodeIfPresent(String.self, forKey: .curationStatus)
        license = try container.decodeIfPresent(String.self, forKey: .license)
        interactive = try container.decodeIfPresent(String.self, forKey: .interactive)
        version = try container.decodeIfPresent(String.self, forKey: .version)
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        
        if let animationLengthString = try? container.decodeIfPresent(String.self, forKey: .animationLength) {
            animationLength = Double(animationLengthString)
        } else if let animationLengthDouble = try? container.decodeIfPresent(Double.self, forKey: .animationLength) {
            animationLength = animationLengthDouble
        } else {
            animationLength = nil
        }
        
        if let animationLengthInSecondsString = try? container.decodeIfPresent(String.self, forKey: .animationLengthInSeconds) {
            animationLengthInSeconds = Double(animationLengthInSecondsString)
        } else if let animationLengthInSecondsDouble = try? container.decodeIfPresent(Double.self, forKey: .animationLengthInSeconds) {
            animationLengthInSeconds = animationLengthInSecondsDouble
        } else {
            animationLengthInSeconds = nil
        }
        
        if let aspectRatioString = try? container.decodeIfPresent(String.self, forKey: .aspectRatio) {
            aspectRatio = Double(aspectRatioString)
        } else if let aspectRatioDouble = try? container.decodeIfPresent(Double.self, forKey: .aspectRatio) {
            aspectRatio = aspectRatioDouble
        } else {
            aspectRatio = nil
        }
    }
}

struct Token: Codable {
    let hash: String
    let tokenId: String
    let invocation: Int
    
    enum CodingKeys: String, CodingKey {
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
