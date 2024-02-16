// ∅ nft-folder-macos 2024

import SwiftUI

struct MetadataView: View {
    
    private var metadata: DetailedTokenMetadata?
    
    init(metadata: DetailedTokenMetadata?) {
        self.metadata = metadata
    }
    
    var body: some View {
        Text(metadata?.toDictionary()?.description ?? "wip. try with a new folder.").frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}
