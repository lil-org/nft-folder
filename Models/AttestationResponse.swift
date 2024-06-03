// ∅ nft-folder 2024

import Foundation

struct AttestationResponse: Codable {
    let data: AttestationData
}

struct AttestationData: Codable {
    let attestations: [Attestation]
}

struct Attestation: Codable {
    let attester: String
    let recipient: String
    let decodedDataJson: String
    let timeCreated: Int
}
