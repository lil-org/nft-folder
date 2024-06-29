// ∅ nft-folder 2024

import Cocoa

extension NSImage {
    
    // TODO: crop to square
    
    func resizeToUseAsCoverIfNeeded() -> (NSImage, Data)? {
        let maxDimension: CGFloat = 130
        var newSize = size
        
        if size.width > maxDimension || size.height > maxDimension {
            let aspectRatio = size.width / size.height
            if aspectRatio > 1 {
                newSize = NSSize(width: maxDimension, height: floor(maxDimension / aspectRatio))
            } else {
                newSize = NSSize(width: floor(maxDimension * aspectRatio), height: maxDimension)
            }
        }
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizedImage.unlockFocus()
        
        guard let tiffData = resizedImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else { return nil }
        
        return (resizedImage, jpegData)
    }
    
}
