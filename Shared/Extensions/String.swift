// ∅ 2025 lil org

import Foundation

extension String {
    
    static func paddedHexString(cid: String, folderType: UInt32) -> String {
        let data = Data(cid.utf8)
        let hexString = data.map { String(format: "%02x", $0) }.joined()
        let offset = 64
        let offsetHex = String(format: "%064x", offset)
        let lengthHex = String(format: "%064x", cid.count)
        let arg1Hex = String(format: "%064x", folderType)
        let paddedHexString = hexString.padding(toLength: ((hexString.count + 63) / 64) * 64, withPad: "00", startingAt: 0)
        let result = "0x" + offsetHex + arg1Hex + lengthHex + paddedHexString
        return result
    }
    
}
