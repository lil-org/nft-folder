// nft-folder-macos 2023 ethistanbul

import Cocoa

struct FolderIcon {
    
    static func set(for wallet: WatchOnlyWallet) {
        guard let avatar = wallet.avatar,
              let imageURL = URL(string: avatar),
              let folderURL = URL.nftDirectory(wallet: wallet) else { return }
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil else { return }
            guard let image = NSImage(data: data) else { return }
            DispatchQueue.main.async {
                NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: [])
            }
        }
        task.resume()
        
    }
    
}
