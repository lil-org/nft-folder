// ∅ nft-folder 2024

import Foundation

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
