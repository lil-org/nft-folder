// ∅ nft-folder 2024

import Foundation

struct SuggestedItem: Identifiable, Hashable {
    
    var id: String { address }
    
    var network: Network {
        return Network(rawValue: chainId) ?? .ethereum
    }
    
    let name: String
    let address: String
    let chainId: Int
    
    static let all: [SuggestedItem] = [
        SuggestedItem(name: "Allstarz Official", address: "0xec0a7a26456b8451aefc4b00393ce1beff5eb3e9", chainId: 1),
        SuggestedItem(name: "Pudgy Penguins", address: "0xbd3531da5cf5857e7cfaa92426877b022e612cf8", chainId: 1),
        SuggestedItem(name: "Creature World", address: "0xc92ceddfb8dd984a89fb494c376f9a48b999aafc", chainId: 1),
        SuggestedItem(name: "Chromie Squiggle", address: "0x059edd72cd353df5106d2b9cc5ab83a52287ac3a", chainId: 1),
        SuggestedItem(name: "Peaceful Groupies", address: "0x4f89cd0cae1e54d98db6a80150a824a533502eea", chainId: 1),
        SuggestedItem(name: "Fidenza", address: "0xa7d8d9ef8d8ce8992df33d8b8cf4aebabd5bd270", chainId: 1),
        SuggestedItem(name: "Very Internet Person", address: "0xfed18c828277e3bd8610f9bae432e65a651706f7", chainId: 1)
    ]
    
    func doNotSuggestAnymore() {
        // TODO: store id to remove from suggestions
    }
    
}
