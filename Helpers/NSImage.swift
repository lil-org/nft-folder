// ∅ nft-folder 2024

import Cocoa

extension NSImage {
    
    func resizeToUseAsCoverIfNeeded() -> (NSImage, Data)? {
        let maxDimension: CGFloat = 130
        let newSize = CGSize(width: maxDimension, height: maxDimension)
        var targetRect = NSRect(x: 0, y: 0, width: maxDimension, height: maxDimension)
        
        if size.width > maxDimension || size.height > maxDimension {
            let aspectRatio = size.width / size.height
            if aspectRatio > 1 {
                let widthToCrop = maxDimension * (aspectRatio - 1)
                targetRect = targetRect.insetBy(dx: -widthToCrop, dy: 0)
            } else {
                let heightToCrop = maxDimension * (1 / aspectRatio - 1)
                targetRect = targetRect.insetBy(dx: 0, dy: -heightToCrop)
            }
        }
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        draw(in: targetRect)
        resizedImage.unlockFocus()
        
        guard let tiffData = resizedImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else { return nil }
        
        return (resizedImage, jpegData)
    }
    
}
