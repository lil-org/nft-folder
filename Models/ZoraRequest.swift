// ∅ nft-folder-macos 2024

import Foundation

struct ZoraRequest {
    
    enum Kind {
        case owner(address: String)
        case collection(address: String)
    }
    
    enum Sort: String {
        case minted, transferred, none
    }
    
    static func query(kind: Kind, sort: Sort, networks: [Network], endCursor: String?) -> [String: String] {
        let whereString: String
        switch kind {
        case .owner(let address):
            whereString = "{ownerAddresses: [\"\(address)\"]}"
        case .collection(let address):
            whereString = "{collectionAddresses: [\"\(address)\"]}"
        }
        let endString: String
        if let endCursor = endCursor {
            endString = ", after:\"\(endCursor)\""
        } else {
            endString = ""
        }
        let networksString = networks.map { $0.query }.joined(separator: ", ")
        
        let queryString = """
        {
            tokens(sort: {sortKey: \(sort.rawValue.uppercased()), sortDirection: DESC},
                networks: [\(networksString)],
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
