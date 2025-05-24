// ∅ 2025 lil org

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
        FooterLink(url: URL.github, imageName: "github"),
        FooterLink(url: URL.x, imageName: "x"),
        FooterLink(url: URL.farcaster, imageName: "fc"),
    ]
    
}
