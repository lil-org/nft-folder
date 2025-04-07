// ∅ 2025 lil org

import Foundation

class WalletDownloader {
    
    private var tmpOnlyNetwork = Network.mainnet
    private var didStudy = false
    private var completion: () -> Void
    private var bundledTokensIdsWithAddresses = Set<String>()
    
    private lazy var fileDownloader = FileDownloader { [weak self] in
        if self?.didStudy == true {
            self?.completion()
        }
    }
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func study(wallet: WatchOnlyWallet) {
        let shouldGoThroughNfts = processBundledTokensAndSeeIfShouldGoThroughNfts(wallet: wallet)
        
        if shouldGoThroughNfts {
            goThroughNfts(wallet: wallet)
        } else {
            didStudy = true
        }
        
        if !wallet.isCollection {
            getFolders(wallet: wallet)
        }
    }
    
    private func processBundledTokensAndSeeIfShouldGoThroughNfts(wallet: WatchOnlyWallet) -> Bool {
        guard let collection = wallet.collections?.first else { return true }
        if let bundledTokens = SuggestedItemsService.bundledTokens(collectionId: wallet.id),
           let walletRootDirectory = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) {
            let isComplete = bundledTokens.isComplete
            var tasks = [DownloadFileTask]()
            for item in bundledTokens.items.shuffled() {
                let name: String?
                let contentRepresentations: [ContentRepresentation]
                if let sh = item.sh {
                    guard let content = ContentRepresentation(url: "https://cdn.simplehash.com/assets/\(sh)", size: nil, mimeType: nil, knownKind: nil) else { continue }
                    contentRepresentations = [content]
                    name = item.name
                } else if let url = item.url {
                    guard let content = ContentRepresentation(url: url, size: nil, mimeType: nil, knownKind: nil) else { continue }
                    contentRepresentations = [content]
                    name = item.name
                } else {
                    if let imageContent = ContentRepresentation(url: "https://media-proxy.artblocks.io/\(wallet.address)/\(item.id).png",
                                                                size: nil, mimeType: nil, knownKind: .image) {
                        contentRepresentations = [imageContent]
                        if let knownName = item.name {
                            name = knownName
                        } else if let projectId = wallet.projectId, item.id.hasPrefix(projectId), item.id != projectId {
                            let cleanId = item.id.dropFirst(projectId.count).drop(while: { $0 == "0" })
                            name = collection.name + " #" + (cleanId.isEmpty ? "0" : cleanId)
                        } else {
                            name = nil
                        }
                    } else {
                        continue
                    }
                }
                
                if !isComplete {
                    bundledTokensIdsWithAddresses.insert(item.id + wallet.address)
                }
                
                let detailedMetadata = DetailedTokenMetadata(name: name, collectionName: collection.name, collectionAddress: wallet.address, tokenId: item.id, chain: wallet.chain, network: collection.network, tokenStandard: nil, contentRepresentations: contentRepresentations)
                guard !MetadataStorage.hasSomethingFor(detailedMetadata: detailedMetadata, addressDirectoryURL: walletRootDirectory) else { continue }
                let minimalMetadata = MinimalTokenMetadata(tokenId: item.id, collectionAddress: wallet.address, chain: wallet.chain, network: collection.network)
                let downloadTask = DownloadFileTask(walletRootDirectory: walletRootDirectory, minimalMetadata: minimalMetadata, detailedMetadata: detailedMetadata)
                tasks.append(downloadTask)
            }
            fileDownloader.addTasks(tasks, wallet: wallet)
            return !isComplete
        } else {
            return true
        }
    }
    
    private func getFolders(wallet: WatchOnlyWallet) {
        FolderSyncService.getOnchainSyncedFolder(wallet: wallet) { [weak self] snapshot in
            guard let snapshot = snapshot else { return }
            self?.applyFolderSnapshotIfNeeded(snapshot, for: wallet)
        }
        
        if let foldersFileURL = URL.foldersForUpcomingTokens(wallet: wallet),
           FileManager.default.fileExists(atPath: foldersFileURL.path),
           let data = try? Data(contentsOf: foldersFileURL),
           let model = try? JSONDecoder().decode(RemainingFoldersForTokens.self, from: data) {
            fileDownloader.useFoldersForTokens(model.dict, wallet: wallet)
        }
    }
    
    private func goThroughNfts(wallet: WatchOnlyWallet) {
        goThroughNfts(wallet: wallet, nextCursor: nil)
    }
    
    private func nextStepForNfts(wallet: WatchOnlyWallet, nextCursor: String?) {
        if nextCursor != nil {
            goThroughNfts(wallet: wallet, nextCursor: nextCursor)
        } else {
            didStudy = true
            if !fileDownloader.hasPendingTasks {
                completion()
            }
        }
    }
    
    private func goThroughNfts(wallet: WatchOnlyWallet, nextCursor: String?) {
        let completion: (NftsResponse?) -> Void = { [weak self] result in
            guard let nfts = result?.nfts, !nfts.isEmpty else {
                self?.nextStepForNfts(wallet: wallet, nextCursor: nil)
                return
            }
            
            self?.processResultNfts(nfts, wallet: wallet)
            
            if let nextCursor = result?.next {
                self?.nextStepForNfts(wallet: wallet, nextCursor: nextCursor)
            }
        }
        
        if wallet.isCollection {
            // TODO: get collection tokens with opensea api
            // RawNftsApi.get(collection: wallet.address, nextCursor: nextCursor, completion: completion)
        } else {
            RawNftsApi.get(owner: wallet.address, nextCursor: nextCursor, completion: completion)
        }
    }
    
    private func processResultNfts(_ nfts: [OpenSeaNft], wallet: WatchOnlyWallet) {
        guard let destination = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return }
        let newNodes = bundledTokensIdsWithAddresses.isEmpty ? nfts : nfts.filter { !bundledTokensIdsWithAddresses.contains($0.identifier + $0.contract) }
        let tasks = newNodes.map { nft -> DownloadFileTask in
            let minimal = MinimalTokenMetadata(tokenId: nft.identifier, collectionAddress: nft.contract, chain: wallet.chain, network: .mainnet)
            let detailed = nft.detailedMetadata(network: tmpOnlyNetwork)
            return DownloadFileTask(walletRootDirectory: destination, minimalMetadata: minimal, detailedMetadata: detailed)
        }
        fileDownloader.addTasks(tasks, wallet: wallet)
    }
    
    private func applyFolderSnapshotIfNeeded(_ snapshot: Snapshot, for wallet: WatchOnlyWallet) {
        var allTokensToOrganize = [Token: [String]]()
        
        for folder in snapshot.folders where !folder.name.isEmpty {
            for token in folder.tokens {
                if let otherFolders = allTokensToOrganize[token] {
                    allTokensToOrganize[token] = otherFolders + [folder.name]
                } else {
                    allTokensToOrganize[token] = [folder.name]
                }
            }
        }
        
        FileDownloader.queue.async { [weak self] in
            guard let foldersForUpcomingTokensFileURL = URL.foldersForUpcomingTokens(wallet: wallet) else { return }
            try? FileManager.default.removeItem(at: foldersForUpcomingTokensFileURL)
            
            if let remaining = self?.organizeAlreadyDownloadedFiles(tokens: allTokensToOrganize, wallet: wallet) {
                if let cid = snapshot.cid {
                    Defaults.addKnownFolderCid(cid, isCidAttested: true, for: wallet)
                }
                
                if !remaining.isEmpty {
                    self?.fileDownloader.useFoldersForTokens(remaining, wallet: wallet)
                    let model = RemainingFoldersForTokens(dict: remaining)
                    let data = try? JSONEncoder().encode(model)
                    try? data?.write(to: foldersForUpcomingTokensFileURL, options: .atomic)
                }
            }
        }
    }
    
    private func organizeAlreadyDownloadedFiles(tokens: [Token: [String]], wallet: WatchOnlyWallet) -> [Token: [String]] {
        var wipTokens = tokens
        guard let baseURL = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return [:] }
        
        let fileManager = FileManager.default
        
        func goThroughFolder(url: URL) {
            guard let folderContents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) else { return }
            for content in folderContents {
                if content.hasDirectoryPath {
                    goThroughFolder(url: content)
                } else if let metadata = MetadataStorage.minimalMetadata(filePath: content.path) {
                    let token = Token(id: metadata.tokenId, address: metadata.collectionAddress, chainId: String(metadata.network.rawValue), comment: nil)
                    if let folders = wipTokens[token], !folders.isEmpty {
                        for (index, folder) in folders.enumerated() {
                            let shouldCopyInsteadOfMoving = index < folders.count - 1
                            let destinationFolderURL = baseURL.appendingPathComponent(folder)
                            if !fileManager.fileExists(atPath: destinationFolderURL.path) {
                                try? fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: false, attributes: nil)
                            }
                            
                            let destinationTokenURL = destinationFolderURL.appending(component: content.lastPathComponent)
                            if content != destinationTokenURL {
                                if shouldCopyInsteadOfMoving {
                                    try? fileManager.copyItem(at: content, to: destinationTokenURL)
                                    MetadataStorage.store(minimalMetadata: metadata, filePath: destinationTokenURL.path)
                                } else {
                                    try? fileManager.moveItem(at: content, to: destinationTokenURL)
                                }
                            }
                        }
                        wipTokens.removeValue(forKey: token)
                        if wipTokens.isEmpty {
                            return
                        }
                    }
                }
            }
        }
        
        goThroughFolder(url: baseURL)
        return wipTokens
    }
    
    deinit {
        fileDownloader.invalidateAndCancel()
    }
    
}
