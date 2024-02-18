// ∅ nft-folder-macos 2024

import Foundation

struct ZoraRequest {
    
    static func query(whereString: String, networks: [Network], endCursor: String?) -> [String: String] {
        let endString: String
        if let endCursor = endCursor {
            endString = ", after:\"\(endCursor)\""
        } else {
            endString = ""
        }
        let networksString = networks.map { $0.query }.joined(separator: ", ")
        
        let queryString = """
        {
          tokens(networks: [\(networksString)],
                 pagination: {limit: 30\(endString)},
                 where: \(whereString))
          {
            pageInfo {
              endCursor
              hasNextPage
            }
            nodes {
              token {
                tokenId
                name
                owner
                collectionName
                collectionAddress
                tokenUrl
                tokenStandard
                image {
                  url
                  mimeType
                  mediaEncoding {
                  ... on ImageEncodingTypes {
                      original
                      thumbnail
                    }
                  }
                }
                content {
                    url
                    mimeType
                }
              }
            }
          }
        }
        """
        return ["query": queryString]
    }
    
}
