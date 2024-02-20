// ∅ nft-folder-macos 2024

import SwiftUI
import Combine

struct WalletImageView: View {
    @StateObject private var imageLoader = ImageLoader()
    let url: URL?
    let address: String

    init(wallet: WatchOnlyWallet) {
        self.address = wallet.address
        if let avatar = wallet.avatar, let url = URL(string: avatar) {
            self.url = url
        } else {
            self.url = nil
        }
        _imageLoader = StateObject(wrappedValue: ImageLoader())
    }

    var body: some View {
        Group {
            if let imageData = imageLoader.imageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            } else {
                Image(nsImage: Blockies(seed: address.lowercased()).createImage() ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            }
        }
        .onAppear {
            if let url = url {
                imageLoader.loadImage(from: url)
            }
        }
    }
}

private class ImageLoader: ObservableObject {
    @Published var imageData: Data?

    func loadImage(from url: URL) {
        // TODO: cache / use from cache
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self.imageData = data
            }
        }.resume()
    }
}
