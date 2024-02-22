// ∅ nft-folder-macos 2024

import Foundation

class WalletDownloader {
    
    static let shared = WalletDownloader()
    private init() {}
    private let urlSession = URLSession.shared
    private let fileDownloader = FileDownloader.shared
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
        ZoraApi.get(owner: wallet.address, networks: [network], endCursor: endCursor) { result in
            guard let result = result, !result.nodes.isEmpty else {
                self.nextStepForZora(wallet: wallet, networkIndex: networkIndex, endCursor: nil, hasNextPage: false)
                return
            }
            
            self.processResultTokensNodes(result.nodes, wallet: wallet, network: network)
            
            if let endCursor = result.pageInfo.endCursor {
                self.nextStepForZora(wallet: wallet, networkIndex: networkIndex, endCursor: endCursor, hasNextPage: result.pageInfo.hasNextPage)
            }
        }
    }
    
    private func processResultTokensNodes(_ nodes: [Node], wallet: WatchOnlyWallet, network: Network) {
        guard let destination = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        
        let tasks = nodes.map { node -> DownloadFileTask in
            let token = node.token
            let minimal = MinimalTokenMetadata(tokenId: token.tokenId, collectionAddress: token.collectionAddress, network: network)
            let detailed = token.detailedMetadata
            return DownloadFileTask(destinationDirectory: destination, minimalMetadata: minimal, detailedMetadata: detailed)
        }
        
        fileDownloader.addTasks(tasks)
    }
    
}
