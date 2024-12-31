// ∅ 2025 lil org

import Cocoa

struct AvatarService {
    
    private static var attemptsCountDict = [String: Int]()
    private static var dict = [String: NSImage]()
    
    private static var lastAccessDate = Date()
    private static var choresTimer: Timer?
    
    static func getAvatarImmediatelly(wallet: WatchOnlyWallet) -> NSImage? {
        lastAccessDate = Date()
        return dict[wallet.id]
    }
    
    static func hasLocalAvatar(wallet: WatchOnlyWallet) -> Bool {
        if dict[wallet.id] != nil {
            return true
        } else if let url = URL.avatarOnDisk(wallet: wallet) {
            return FileManager.default.fileExists(atPath: url.path)
        } else {
            return false
        }
    }
    
    static func makeSureAvatarIsOnDisk(wallet: WatchOnlyWallet, image: NSImage) {
        if let folderURL = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false),
           let url = URL.avatarOnDisk(wallet: wallet),
           !FileManager.default.fileExists(atPath: url.path) {
            if let tiffData = image.tiffRepresentation,
               let bitmapImage = NSBitmapImageRep(data: tiffData),
               let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 1]) {
                NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: [])
                try? jpegData.write(to: url, options: .atomic)
            }
        }
    }
    
    static func setAvatar(wallet: WatchOnlyWallet, image: NSImage) {
        guard let (resizedImage, jpegData) = image.resizeToUseAsCoverIfNeeded(),
              let fileURL = URL.avatarOnDisk(wallet: wallet),
              let folderURL = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        
        DispatchQueue.main.async {
            dict[wallet.id] = resizedImage
            NSWorkspace.shared.setIcon(resizedImage, forFile: folderURL.path, options: [])
            NotificationCenter.default.post(name: .didUpdateWalletAvatar, object: wallet.id)
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
            dict[wallet.id] = image
            return
        }
        
        if let attemptsCount = attemptsCountDict[wallet.id] {
            if attemptsCount > 3 {
                return
            } else {
                attemptsCountDict[wallet.id] = attemptsCount + 1
            }
        } else {
            attemptsCountDict[wallet.id] = 1
        }
        
        guard let urlString = wallet.avatar, let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let image = NSImage(data: data),
                  let (resizedImage, jpegData) = image.resizeToUseAsCoverIfNeeded() else { return }
            DispatchQueue.main.async {
                completion(resizedImage)
                dict[wallet.id] = resizedImage
                NSWorkspace.shared.setIcon(resizedImage, forFile: folderURL.path, options: [])
            }
            try? jpegData.write(to: fileURL, options: .atomic)
        }.resume()
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
