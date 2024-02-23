// ∅ nft-folder-macos 2024

import Cocoa

struct AvatarService {
    
    private static var attemptsCountDict = [String: Int]()
    
    static func getAvatar(wallet: WatchOnlyWallet, completion: @escaping (NSImage) -> Void) {
        guard let urlString = wallet.avatar,
              let url = URL(string: urlString),
              let fileURL = URL.avatarOnDisk(wallet: wallet),
              let folderURL = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        
        if let diskCachedData = try? Data(contentsOf: fileURL), let image = NSImage(data: diskCachedData) {
            completion(image)
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
            completion(image)
            try? data.write(to: fileURL, options: .atomic)
            DispatchQueue.main.async { NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: []) }
        }.resume()
    }
    
}
