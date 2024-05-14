// ∅ nft-folder 2024

import Foundation
import SwiftUI

struct WatchOnlyWallet: Codable, Hashable, Identifiable {
    
    var id: String { address }
    
    let address: String
    let name: String?
    let avatar: String?
    
    let collections: [CollectionInfo]?
    
    var listDisplayName: String {
        if let name = name {
            return name
        } else {
            let clean = address.dropFirst(2)
            let cropped = clean.prefix(4) + "…" + clean.suffix(4)
            return String(cropped)
        }
    }
    
    var folderDisplayName: String {
        if let name = name {
            return name
        } else {
            return address
        }
    }
    
    private static let colors: [Color] = [
        Color(red: 0.75, green: 0.75, blue: 0.8),
        Color(red: 0.8, green: 0.75, blue: 0.75),
        Color(red: 0.8, green: 0.78, blue: 0.75),
        Color(red: 0.78, green: 0.8, blue: 0.75),
        Color(red: 0.75, green: 0.8, blue: 0.75),
        Color(red: 0.75, green: 0.8, blue: 0.78),
        Color(red: 0.75, green: 0.78, blue: 0.8),
        Color(red: 0.75, green: 0.75, blue: 0.8),
        Color(red: 0.77, green: 0.75, blue: 0.8),
        Color(red: 0.78, green: 0.75, blue: 0.8)
    ]

    var placeholderColor: Color {
        var digitsInAddress = 0
        for addressScalar in address.unicodeScalars {
            if CharacterSet.decimalDigits.contains(addressScalar) {
                digitsInAddress += 1
            }
        }
        
        return WatchOnlyWallet.colors[digitsInAddress % WatchOnlyWallet.colors.count].opacity(0.81)
    }
    
}
