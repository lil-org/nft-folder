// nft-folder-macos 2023 ethistanbul

import Foundation

struct Asset: Codable {
    let id: Int
    let tokenId: String
    let permalink: String?
    let animationOriginalUrl: String?
    let description: String?
    let name: String?
    let imageOriginalUrl: String?
    let externalLink: String?
    let chainId: Int
    let assetContract: AssetContract
    
    var probableFileURL: URL? {
        guard var urlString = (animationOriginalUrl ?? imageOriginalUrl) ?? externalLink else { return nil }
        if urlString.hasPrefix(URL.ipfsScheme) {
            urlString = "https://ipfs.io/ipfs/" + urlString.dropFirst(URL.ipfsScheme.count)
        }
        if let url = URL(string: urlString) {
            return url
        } else {
            return nil
        }
    }
    
    var fileDisplayName: String {
        return "\(assetContract.name) - \(name ?? tokenId)"
    }
    
    var openseaURL: URL? {
        if let url = URL(string: "https://opensea.io/assets/ethereum/\(assetContract.address)/\(tokenId)") {
            return url
        } else {
            return nil
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case tokenId = "token_id"
        case animationOriginalUrl = "animation_original_url"
        case description
        case permalink
        case name
        case imageOriginalUrl = "image_original_url"
        case externalLink = "external_link"
        case chainId = "chainId"
        case assetContract = "asset_contract"
    }
}

struct AssetContract: Codable {
    let address: String
    let name: String
    let description: String?
    let createdDate: String
    let externalLink: String?
    let imageUrl: String?
    let assetContractType: String?
    let openseaVersion: String?
    let nftVersion: String?
    let payoutAddress: String?
    let schemaName: String?
    let symbol: String?

    enum CodingKeys: String, CodingKey {
        case address
        case name
        case description
        case createdDate = "created_date"
        case externalLink = "external_link"
        case imageUrl = "image_url"
        case assetContractType = "asset_contract_type"
        case openseaVersion = "opensea_version"
        case nftVersion = "nft_version"
        case payoutAddress = "payout_address"
        case schemaName = "schema_name"
        case symbol
    }
}
