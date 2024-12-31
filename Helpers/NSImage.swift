// ∅ 2025 lil org

import Cocoa

extension NSImage {
    
    func resizeToUseAsCoverIfNeeded() -> (NSImage, Data)? {
        let targetDimension: CGFloat = 150
        let newSize = CGSize(width: targetDimension, height: targetDimension)
        
        let aspectRatio = size.width / size.height
        var scaledSize: CGSize
        
        if aspectRatio > 1 {
            scaledSize = CGSize(width: targetDimension * aspectRatio, height: targetDimension)
        } else {
            scaledSize = CGSize(width: targetDimension, height: targetDimension / aspectRatio)
        }
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        let drawRect = NSRect(origin: CGPoint(x: -(scaledSize.width - newSize.width) / 2, y: -(scaledSize.height - newSize.height) / 2), size: scaledSize)
        draw(in: drawRect)
        resizedImage.unlockFocus()
        
        guard let tiffData = resizedImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else { return nil }
        
        return (resizedImage, jpegData)
    }
    
}
