// ∅ nft-folder-macos 2024

import SwiftUI

struct FooterLink: Hashable {
    
    let url: URL
    let imageName: String
    
    var image: Image {
        return Image(imageName)
    }
    
    static let all = [
        FooterLink(url: URL(string: "mailto:ivan@lil.org")!, imageName: "mail"),
        FooterLink(url: URL(string: "https://github.com/lil-org/nft-folder-macos")!, imageName: "github"),
        FooterLink(url: URL(string: "https://x.ivan.lol")!, imageName: "x"),
        FooterLink(url: URL(string: "https://f.ivan.lol")!, imageName: "fc")
    ]
    
    static let nounsURL = URL(string: "https://prop.house")!
    static let zoraURL = URL(string: "https://docs.zora.co/")!
    
}
