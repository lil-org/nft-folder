// ∅ 2025 lil org

import Foundation

struct AttestationResponse: Codable {
    let data: AttestationData
    
    var cid: String? {
        guard let jsonSting = data.attestations.first?.decodedDataJson,
              let data = jsonSting.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              let valueDict = json.first?["value"] as? [String: String], let cid = valueDict["value"] else { return nil }
        return cid
    }
    
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
