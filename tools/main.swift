// ∅ nft-folder 2024

import Foundation

let dir = FileManager.default.currentDirectoryPath
let url = URL(fileURLWithPath: dir + "/tools/artblocks.json")
let data = try! Data(contentsOf: url)
let artblocks = try! JSONDecoder().decode(Artblocks.self, from: data)

print(artblocks.data.projectsMetadata.count)
