// nft-folder-macos 2023 ethistanbul

import Cocoa

struct FolderIcon {
    
    static func set(for wallet: WatchOnlyWallet) {
        guard let avatar = wallet.avatar,
              let imageURL = URL(string: avatar),
              let folderURL = URL.nftDirectory(wallet: wallet) else {
            setBlockies(for: wallet)
            return
        }
        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil, let image = NSImage(data: data) else {
                setBlockies(for: wallet)
                return
            }
            DispatchQueue.main.async {
                NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: [])
            }
        }
        task.resume()
    }
    
    static private func setBlockies(for wallet: WatchOnlyWallet) {
        DispatchQueue.main.async {
            if let image = Blockies(seed: wallet.address.lowercased()).createImage(),
               let folderURL = URL.nftDirectory(wallet: wallet) {
                NSWorkspace.shared.setIcon(image, forFile: folderURL.path, options: [])
            }
        }
    }
    
}
