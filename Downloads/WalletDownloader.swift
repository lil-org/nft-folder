// ∅ nft-folder-macos 2024

import Foundation

class WalletDownloader {
    
    private var networks = Network.allCases
    private var didStudy = false
    private var completion: () -> Void
    
    private lazy var fileDownloader = FileDownloader { [weak self] in
        if self?.didStudy == true {
            self?.completion()
        }
    }
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func study(wallet: WatchOnlyWallet) {
        // TODO: implement collections downloading
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
        } else {
            didStudy = true
            if !fileDownloader.hasPendingTasks {
                completion()
            }
        }
    }
    
    private func goThroughZora(wallet: WatchOnlyWallet, networkIndex: Int, endCursor: String?) {
        let network = networks[networkIndex]
        ZoraApi.get(owner: wallet.address, networks: [network], endCursor: endCursor) { [weak self] result in
            guard let result = result?.tokens, !result.nodes.isEmpty else {
                self?.nextStepForZora(wallet: wallet, networkIndex: networkIndex, endCursor: nil, hasNextPage: false)
                return
            }
            
            self?.processResultTokensNodes(result.nodes, wallet: wallet, network: network)
            
            if let endCursor = result.pageInfo.endCursor {
                self?.nextStepForZora(wallet: wallet, networkIndex: networkIndex, endCursor: endCursor, hasNextPage: result.pageInfo.hasNextPage)
            }
        }
    }
    
    private func processResultTokensNodes(_ nodes: [Node], wallet: WatchOnlyWallet, network: Network) {
        guard let destination = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        
        let tasks = nodes.map { node -> DownloadFileTask in
            let token = node.token
            let minimal = MinimalTokenMetadata(tokenId: token.tokenId, collectionAddress: token.collectionAddress, network: network)
            let detailed = token.detailedMetadata(network: network)
            return DownloadFileTask(destinationDirectory: destination, minimalMetadata: minimal, detailedMetadata: detailed)
        }
        
        fileDownloader.addTasks(tasks)
    }
    
    deinit {
        fileDownloader.invalidateAndCancel()
    }
    
}
