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
        FooterLink(url: URL(string: "https://github.com/lil-org")!, imageName: "github"),
        FooterLink(url: URL(string: "https://x.com/lildotorg")!, imageName: "x"),
        FooterLink(url: URL(string: "https://zora.co/collect/zora:0x01c077fd6b4df827490cd4f95650d55d6b35c35d")!, imageName: nil),
        FooterLink(url: URL(string: "https://warpcast.com/org")!, imageName: "fc"),
    ]
    
}
