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
        FooterLink(url: URL(string: "https://github.com/lil-org/nft-folder")!, imageName: "github"),
        FooterLink(url: URL(string: "https://x.ivan.lol")!, imageName: "x"),
        FooterLink(url: NftGallery.zora.url(network: .zora, collectionAddress: "0x01c077fd6b4df827490cd4f95650d55d6b35c35d", tokenId: nil)!, imageName: nil),
        FooterLink(url: URL(string: "https://f.ivan.lol")!, imageName: "fc"),
    ]
    
}
