// ∅ nft-folder 2024

import Foundation

let semaphore = DispatchSemaphore(value: 0)
let queue = DispatchQueue(label: UUID().uuidString, qos: .default)
let projectDir = FileManager.default.currentDirectoryPath

translateAppStoreMetadata(.highQuality)
translateAllString(.cheap)
addNewString(key: "greeting", english: "yo", russian: "йо")

print("🟢 all done")
