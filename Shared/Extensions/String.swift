// ∅ nft-folder 2024

import Foundation

extension String {
    
    func toPaddedHexString() -> String {
        let data = Data(utf8)
        let hexString = data.map { String(format: "%02x", $0) }.joined()
        let offsetHex = String(format: "%064x", 32)
        let lengthHex = String(format: "%064x", count)
        let paddedHexString = hexString.padding(toLength: ((hexString.count + 63) / 64) * 64, withPad: "00", startingAt: 0)
        let result = "0x" + offsetHex + lengthHex + paddedHexString
        return result
    }
    
}
