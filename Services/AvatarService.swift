// ∅ nft-folder 2024

import Cocoa

// TODO: clean in-memory cache if there was no opened window for a while

struct AvatarService {
    
    private static var attemptsCountDict = [String: Int]()
    private static var dict = [String: NSImage]()
    
    static func getAvatarImmediatelly(wallet: WatchOnlyWallet) -> NSImage? {
        return dict[wallet.address]
    }
    
    static func getAvatar(wallet: WatchOnlyWallet, completion: @escaping (NSImage) -> Void) {
        if let image = getAvatarImmediatelly(wallet: wallet) {
            completion(image)
            return
        }
        
        guard let urlString = wallet.avatar,
              let url = URL(string: urlString),
              let fileURL = URL.avatarOnDisk(wallet: wallet),
              let folderURL = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        
        if let diskCachedData = try? Data(contentsOf: fileURL), let image = NSImage(data: diskCachedData) {
            completion(image)
            dict[wallet.address] = image
            return
        }
        
        if let attemptsCount = attemptsCountDict[wallet.address] {
            if attemptsCount > 3 {
                return
            } else {
                attemptsCountDict[wallet.address] = attemptsCount + 1
            }
        } else {
            attemptsCountDict[wallet.address] = 1
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let image = NSImage(data: data) else { return }
            let maxDimension: CGFloat = 230
            var newSize = image.size
            
            if image.size.width > maxDimension || image.size.height > maxDimension {
                let aspectRatio = image.size.width / image.size.height
                if aspectRatio > 1 {
                    newSize = NSSize(width: maxDimension, height: maxDimension / aspectRatio)
                } else {
                    newSize = NSSize(width: maxDimension * aspectRatio, height: maxDimension)
                }
            }
            
            let resizedImage = NSImage(size: newSize)
            resizedImage.lockFocus()
            image.draw(in: NSRect(origin: .zero, size: newSize))
            resizedImage.unlockFocus()
            
            guard let tiffData = resizedImage.tiffRepresentation,
                  let bitmapImage = NSBitmapImageRep(data: tiffData),
                  let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else { return }
            
            DispatchQueue.main.async {
                completion(resizedImage)
                dict[wallet.address] = resizedImage
                NSWorkspace.shared.setIcon(resizedImage, forFile: folderURL.path, options: [])
            }
            try? jpegData.write(to: fileURL, options: .atomic)
        }.resume()
    }
    
}
