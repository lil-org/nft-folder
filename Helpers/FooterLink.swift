// ∅ nft-folder 2024

import SwiftUI

struct FooterLink: Hashable {
    
    let url: URL
    let imageName: String?
    
    var image: Image {
        if let imageName = imageName {
            return Image(imageName)
        } else {
            return Images.mint
        }
    }
    
    static let all = [
        FooterLink(url: URL(string: "https://g.lil.org")!, imageName: "github"),
        FooterLink(url: URL(string: "https://x.lil.org")!, imageName: "x"),
        FooterLink(url: URL(string: "https://mint.lil.org")!, imageName: nil),
        FooterLink(url: URL(string: "https://f.lil.org")!, imageName: "fc"),
    ]
    
}
