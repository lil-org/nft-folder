// ∅ nft-folder 2024

import Foundation

struct ZoraRequest {
    
    enum Kind {
        case owner(address: String)
        case collection(address: String)
        case checkIfCollection(address: String)
    }
    
    enum Sort: String {
        case minted, transferred, none
        
        var query: String {
            switch self {
            case .minted, .transferred, .none:
                return rawValue.uppercased()
            }
        }
    }
    
    static func query(kind: Kind, sort: Sort, networks: [Network], endCursor: String?, minimalVersion: Bool) -> [String: String] {
        let contentQuery = minimalVersion ? "" : enabledContentQueryString
        
        let whereString: String
        switch kind {
        case .owner(let address):
            whereString = "{ownerAddresses: [\"\(address)\"]}"
        case .collection(let address), .checkIfCollection(let address):
            whereString = "{collectionAddresses: \"\(address)\"}"
        }
        let endString: String
        if let endCursor = endCursor {
            endString = ", after:\"\(endCursor)\""
        } else {
            endString = ""
        }
        let networksString = networks.map { $0.query }.joined(separator: ", ")
        
        let queryString: String
        
        switch kind {
        case .owner, .collection:
            queryString = """
            {
                tokens(
                    sort: {sortKey: \(sort.query), sortDirection: DESC},
                    networks: [\(networksString)],
                    pagination: {limit: 30\(endString)},
                    where: \(whereString)) {
                
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
                            tokenUrlMimeType
                            tokenStandard
                            image {
                                url
                                mimeType
                                size
                                mediaEncoding {
                                    ... on ImageEncodingTypes {
                                        original
                                        thumbnail
                                    }
                                }
                            }\(contentQuery)
                        }
                    }
                }
            }
            """
        case .checkIfCollection:
            queryString = """
            {
                collections(
                    where: \(whereString)
                    networks: [\(networksString)]
                ) {
                    nodes {
                        name
                        networkInfo {
                            chain
                            network
                        }
                    }
                }
            }
            """
        }
        
        return ["query": queryString]
    }
    
    private static let enabledContentQueryString = {
        return """
        
                        content {
                            url
                            mimeType
                            size
                            mediaEncoding {
                                ... on VideoEncodingTypes {
                                    original
                                    preview
                                }
                                ... on AudioEncodingTypes {
                                    original
                                }
                            }
                        }
        """
    }()
    
}
