// ∅ nft-folder 2024

import SwiftUI

struct RandomGradientShape: View {
    let address: String
    
    var body: some View {
        let colors = generateColors(from: address)
        let gradient = LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
        return Rectangle().fill(gradient)
    }
    
    func generateColors(from address: String) -> [Color] {
        let hash = simpleHash(address)
        return [
            Color(red: Double((hash & 0xFF)) / 255.0, green: Double((hash >> 8 & 0xFF)) / 255.0, blue: Double((hash >> 16 & 0xFF)) / 255.0),
            Color(red: Double((hash >> 24 & 0xFF)) / 255.0, green: Double((hash >> 32 & 0xFF)) / 255.0, blue: Double((hash >> 40 & 0xFF)) / 255.0)
        ]
    }
    
    func simpleHash(_ input: String) -> UInt64 {
        var hash: UInt64 = 0
        for char in input.utf8 {
            hash = (hash &* 31 &+ UInt64(char)) & UInt64.max
        }
        return hash
    }
}
