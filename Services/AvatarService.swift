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
            // TODO: make it smaller if needed, do not store an image too big
            DispatchQueue.main.async {
                completion(image)
                dict[wallet.address] = image
                NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: [])
            }
            try? data.write(to: fileURL, options: .atomic)
        }.resume()
    }
    
}
