// ∅ nft-folder-macos 2024

import SwiftUI

struct MetadataView: View {
    
    private var metadata: DetailedTokenMetadata
    
    init(metadata: DetailedTokenMetadata) {
        self.metadata = metadata
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let name = metadata.name, !name.isEmpty {
                    Text("name: \(name)")
                        .font(.headline)
                }
                if let collectionName = metadata.collectionName, !collectionName.isEmpty {
                    Text("collection: \(collectionName)")
                }
                Text("collection address: \(metadata.collectionAddress)")
                Text("token id: \(metadata.tokenId)")
                if let description = metadata.description, !description.isEmpty {
                    Text("description: \(description)")
                }
                Text("network: \(metadata.network.name.lowercased())")
                if let tokenStandard = metadata.tokenStandard {
                    Text("\(tokenStandard)")
                }
                
                ForEach(metadata.contentRepresentations, id: \.self.size) { representation in
                    if case let .url(url) = representation.dataOrUrl {
                        Link("\((representation.kind ?? .other).rawValue)", destination: url)
                    }
                }
            }
            .padding()
        }
    }
    
}
