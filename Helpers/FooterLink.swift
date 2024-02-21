// ∅ nft-folder-macos 2024

import SwiftUI

struct FooterLink: Hashable {
    
    let url: URL
    let imageName: String
    
    var image: Image {
        return Image(imageName)
    }
    
    // TODO: setup images
    static let all = [
        FooterLink(url: URL(string: "mailto:ivan@lil.org")!, imageName: ""),
        FooterLink(url: URL(string: "https://github.com/lil-org/nft-folder-macos")!, imageName: ""),
        FooterLink(url: URL(string: "https://x.ivan.lol")!, imageName: ""),
        FooterLink(url: URL(string: "https://f.ivan.lol")!, imageName: "")
    ]
    
    static let nounsURL = URL(string: "https://prop.house")!
    static let zoraURL = URL(string: "https://docs.zora.co/")!
    
}
