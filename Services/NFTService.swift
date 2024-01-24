// ∅ nft-folder-macos 2024

import Foundation

class NFTService {
    
    static let shared = NFTService()
    private init() {}
    private let urlSession = URLSession.shared
    private let downloadsService = DownloadsService.shared
    private var networks = Network.allCases
    
    func study(wallet: WatchOnlyWallet) {
        goThroughZora(wallet: wallet)
    }
    
    private func goThroughZora(wallet: WatchOnlyWallet) {
        goThroughZora(wallet: wallet, networkIndex: 0, endCursor: nil)
    }
    
    private func nextStepForZora(wallet: WatchOnlyWallet, networkIndex: Int, endCursor: String?, hasNextPage: Bool) {
        if hasNextPage {
            goThroughZora(wallet: wallet, networkIndex: networkIndex, endCursor: endCursor)
        } else if networkIndex + 1 < networks.count {
            goThroughZora(wallet: wallet, networkIndex: networkIndex + 1, endCursor: nil)
        }
    }
    
    private func goThroughZora(wallet: WatchOnlyWallet, networkIndex: Int, endCursor: String?) {
        let network = networks[networkIndex]
        ZoraAPI.get(owner: wallet.address, networks: [network], endCursor: endCursor) { result in
            print("zora api result: \(String(describing: result))")
            guard let result = result, !result.nodes.isEmpty else {
                self.nextStepForZora(wallet: wallet, networkIndex: networkIndex, endCursor: nil, hasNextPage: false)
                // TODO: retry, handle errors
                return
            }
            self.downloadsService.downloadFiles(wallet: wallet, downloadables: result.nodes.map { $0.token }, network: network)
            if let endCursor = result.pageInfo.endCursor {
                self.nextStepForZora(wallet: wallet, networkIndex: networkIndex, endCursor: endCursor, hasNextPage: result.pageInfo.hasNextPage)
            }
        }
    }
    
}
