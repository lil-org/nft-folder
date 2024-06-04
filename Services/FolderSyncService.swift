// ∅ nft-folder 2024

import Cocoa

struct FolderSyncService {
    
    static func pushCustomFolders(wallet: WatchOnlyWallet) {
        showConfirmationAlert(wallet: wallet)
    }
    
    static func getSyncedFolder(wallet: WatchOnlyWallet) {
        let url = URL(string: "\(URL.easScanBase)/graphql")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let query: [String: Any] = [
            "query": """
                query Attestation {
                    attestations(
                        take: 1,
                        orderBy: { timeCreated: desc},
                        where: { schemaId: { equals: "\(URL.nftFolderAttestationSchema)" }, recipient: { equals: "\(wallet.address)" }, attester: { equals: "\(wallet.address)" } }
                    ) {
                        attester
                        recipient
                        decodedDataJson
                        timeCreated
                    }
                }
            """,
            "variables": [:]
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: query) else { return }
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            // TODO: retry when appropriate
            if let data = data, let attestationResponse = try? JSONDecoder().decode(AttestationResponse.self, from: data), let cid = attestationResponse.cid {
                getSyncedFolderFromIpfs(cid: cid)
            }
        }
        
        task.resume()
    }
    
    private static func getSyncedFolderFromIpfs(cid: String) {
        guard let url = URL(string: URL.ipfsGateway + cid) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            // TODO: retry when appropriate
            if let data = data, let syncedFolder = try? JSONDecoder().decode(SyncedFolder.self, from: data) {
                // TODO: use synced folder to organize nfts
            }
        }
        
        task.resume()
    }
    
    private static func showConfirmationAlert(wallet: WatchOnlyWallet) {
        getSyncedFolder(wallet: wallet) // TODO: dev tmp
        
        let alert = NSAlert()
        alert.messageText = Strings.pushCustomFolders + "?"
        alert.informativeText = wallet.folderDisplayName
        alert.alertStyle = .informational
        alert.addButton(withTitle: Strings.ok)
        alert.addButton(withTitle: Strings.cancel)
        alert.buttons.last?.keyEquivalent = "\u{1b}"
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            uploadFoldersToIpfsAndSaveOnchain(wallet: wallet)
        default:
            break
        }
    }
    
    private static func uploadFoldersToIpfsAndSaveOnchain(wallet: WatchOnlyWallet) {
        // TODO: check if folders were changed
        
        guard let folder = folderToSync(wallet: wallet), let fileData = try? JSONEncoder().encode(folder) else {
            showErrorAlert()
            return
        }
        
        IpfsUploader.upload(name: wallet.address, mimeType: "application/json", data: fileData) { cid in
            if let cid = cid, let url = URL.attestFolder(address: wallet.address, cid: cid) {
                NSWorkspace.shared.open(url)
            } else {
                showErrorAlert()
            }
        }
    }
    
    private static func folderToSync(wallet: WatchOnlyWallet) -> SyncedFolder? {
        guard let url = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return nil }
        let folder = folderToSync(url: url)
        return folder
    }
    
    private static func folderToSync(url: URL) -> SyncedFolder {
        let fileManager = FileManager.default
        
        var nfts = [NftInSyncedFolder]()
        var childrenFolders = [SyncedFolder]()
        
        if let folderContents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for content in folderContents {
                if content.hasDirectoryPath {
                    let childFolder = folderToSync(url: content)
                    childrenFolders.append(childFolder)
                } else if let metadata = MetadataStorage.minimalMetadata(filePath: content.path) {
                    let nft = NftInSyncedFolder(chainId: String(metadata.network.rawValue), tokenId: metadata.tokenId, address: metadata.collectionAddress)
                    nfts.append(nft)
                }
            }
        }
        
        return SyncedFolder(name: url.lastPathComponent, nfts: nfts, childrenFolders: childrenFolders)
    }
    
    private static func showErrorAlert() {
        let alert = NSAlert()
        alert.messageText = Strings.somethingWentWrong
        alert.alertStyle = .warning
        _ = alert.runModal()
    }
    
}
