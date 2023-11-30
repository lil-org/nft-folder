// nft-folder-macos 2023 ethistanbul

import Foundation

struct NFTService {
    
    static let shared = NFTService()
    private init() {}
    private let urlSession = URLSession.shared
    private let apiKey = Secrets.inchApiKey
    private let downloadsService = DownloadsService.shared
    
    func study(wallet: WatchOnlyWallet) {
        goThroughZora(wallet: wallet)
        goThroughOneInch(wallet: wallet)
    }
    
    private func goThroughOneInch(wallet: WatchOnlyWallet, offset: Int = 0) {
        InchAPI.shared.getNFTs(address: wallet.address, limit: 200, offset: offset) { assets in
            downloadsService.downloadFiles(wallet: wallet, downloadables: assets)
            if !assets.isEmpty {
                goThroughOneInch(wallet: wallet, offset: offset + assets.count)
            }
        }
    }
    
    private func goThroughZora(wallet: WatchOnlyWallet, endCursor: String? = nil) {
        ZoraAPI.get(owner: wallet.address, networks: [.zora], endCursor: nil) { result in
            guard let result = result else { return } // TODO: handle errors, retry
            downloadsService.downloadFiles(wallet: wallet, downloadables: result.nodes.map { $0.token })
            if result.pageInfo.hasNextPage, let endCursor = result.pageInfo.endCursor {
                goThroughZora(wallet: wallet, endCursor: endCursor)
            }
        }
    }
    
}
