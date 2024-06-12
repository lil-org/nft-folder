// ∅ nft-folder 2024

import Foundation

enum MetadataKind: String {
    case description
    case keywords
    case name
    case subtitle
    case promotionalText = "promotional_text"
    case releaseNotes = "release_notes"
}

translateAppStoreMetadata()

func translateAppStoreMetadata() {
    print("yo")
    // TODO: go trough all locales
    // TODO: use en and ru versions as a reference
    // TODO: check if there were changes since the last translation run
}
