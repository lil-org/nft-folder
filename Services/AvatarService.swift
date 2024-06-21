// ∅ nft-folder 2024

import Cocoa

struct AvatarService {
    
    private static var attemptsCountDict = [String: Int]()
    private static var dict = [String: NSImage]()
    
    private static var lastAccessDate = Date()
    private static var choresTimer: Timer?
    
    static func getAvatarImmediatelly(wallet: WatchOnlyWallet) -> NSImage? {
        lastAccessDate = Date()
        return dict[wallet.address]
    }
    
    static func hasLocalAvatar(wallet: WatchOnlyWallet) -> Bool {
        if dict[wallet.address] != nil {
            return true
        } else if let url = URL.avatarOnDisk(wallet: wallet) {
            return FileManager.default.fileExists(atPath: url.path)
        } else {
            return false
        }
    }
    
    static func setAvatar(wallet: WatchOnlyWallet, image: NSImage) {
        guard let (resizedImage, jpegData) = resizeImageIfNeeded(image),
              let fileURL = URL.avatarOnDisk(wallet: wallet),
              let folderURL = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        
        DispatchQueue.main.async {
            dict[wallet.address] = resizedImage
            NSWorkspace.shared.setIcon(resizedImage, forFile: folderURL.path, options: [])
            NotificationCenter.default.post(name: .didUpdateWalletAvatar, object: wallet.address)
        }
        
        try? jpegData.write(to: fileURL, options: .atomic)
    }
    
    static func getAvatar(wallet: WatchOnlyWallet, completion: @escaping (NSImage) -> Void) {
        if let image = getAvatarImmediatelly(wallet: wallet) {
            completion(image)
            return
        }
        
        guard let fileURL = URL.avatarOnDisk(wallet: wallet),
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
        
        guard let urlString = wallet.avatar, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let image = NSImage(data: data),
                  let (resizedImage, jpegData) = resizeImageIfNeeded(image) else { return }
            DispatchQueue.main.async {
                completion(resizedImage)
                dict[wallet.address] = resizedImage
                NSWorkspace.shared.setIcon(resizedImage, forFile: folderURL.path, options: [])
            }
            try? jpegData.write(to: fileURL, options: .atomic)
        }.resume()
    }
    
    private static func resizeImageIfNeeded(_ image: NSImage) -> (NSImage, Data)? {
        let maxDimension: CGFloat = 130
        var newSize = image.size
        
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let aspectRatio = image.size.width / image.size.height
            if aspectRatio > 1 {
                newSize = NSSize(width: maxDimension, height: floor(maxDimension / aspectRatio))
            } else {
                newSize = NSSize(width: floor(maxDimension * aspectRatio), height: maxDimension)
            }
        }
        
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        image.draw(in: NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        resizedImage.unlockFocus()
        
        guard let tiffData = resizedImage.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.9]) else { return nil }
        
        return (resizedImage, jpegData)
    }
    
    static func setup() {
        NotificationCenter.default.addObserver(forName: NSApplication.didResignActiveNotification, object: nil, queue: nil) { _ in
            scheduleChoresTimer()
        }
        
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: nil) { _ in
            choresTimer?.invalidate()
        }
    }
    
    private static func scheduleChoresTimer() {
        let timeDelta = TimeInterval(300)
        choresTimer?.invalidate()
        choresTimer = Timer.scheduledTimer(withTimeInterval: timeDelta, repeats: false) { _ in
            DispatchQueue.main.async {
                if Date().timeIntervalSince(lastAccessDate) >= timeDelta && !Window.thereAreSome {
                    dict.removeAll()
                } else {
                    scheduleChoresTimer()
                }
            }
        }
    }
    
}
