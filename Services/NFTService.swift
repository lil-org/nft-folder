// nft-folder-macos 2023 ethistanbul

import Foundation

class NFTService {
    
    static let shared = NFTService()
    private init() {}
    private let urlSession = URLSession.shared
    private let apiKey = Secrets.inchApiKey
    private let downloadsService = DownloadsService.shared
    private var networks = Network.allCases
    private var addressesWithSomeDownloads = Set<String>()
    
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
        } else if !addressesWithSomeDownloads.contains(wallet.address) {
            goThroughOneInch(wallet: wallet, offset: 0)
        }
    }
    
    private func goThroughZora(wallet: WatchOnlyWallet, networkIndex: Int, endCursor: String?) {
        let network = networks[networkIndex]
        ZoraAPI.get(owner: wallet.address, networks: [network], endCursor: endCursor) { result in
            guard let result = result else {
                self.nextStepForZora(wallet: wallet, networkIndex: networkIndex, endCursor: nil, hasNextPage: false)
                // TODO: retry, handle errors
                return
            }
            self.downloadsService.downloadFiles(wallet: wallet, downloadables: result.nodes.map { $0.token }, network: network)
            self.addressesWithSomeDownloads.insert(wallet.address)
            if let endCursor = result.pageInfo.endCursor {
                self.nextStepForZora(wallet: wallet, networkIndex: networkIndex, endCursor: endCursor, hasNextPage: result.pageInfo.hasNextPage)
            }
        }
    }
    
    private func goThroughOneInch(wallet: WatchOnlyWallet, offset: Int) {
        InchAPI.shared.getNFTs(address: wallet.address, limit: 200, offset: offset) { assets in
            self.downloadsService.downloadFiles(wallet: wallet, downloadables: assets, network: .ethereum)
            if !assets.isEmpty {
                self.goThroughOneInch(wallet: wallet, offset: offset + assets.count)
            }
        }
    }
    
}
