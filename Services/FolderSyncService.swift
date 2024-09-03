// ∅ nft-folder 2024

import Foundation

struct FolderSyncService {
    
    private enum AttestationType {
        case createFolder, updateFolder
    }
    
    static func pushCustomFolders(wallet: WatchOnlyWallet, completion: @escaping (URL?) -> Void) {
        guard let snapshot = makeFoldersSnapshot(wallet: wallet), let fileData = try? JSONEncoder().encode(snapshot) else {
            completion(nil)
            return
        }
        
        IpfsUploader.upload(name: wallet.address, mimeType: "application/json", data: fileData) { cid in
            if let cid = cid, let url = URL.newAttestation(recipient: wallet.address, cid: cid, folderType: FolderType.organized.rawValue) {
                Defaults.addKnownFolderCid(cid, isCidAttested: false, for: wallet)
                completion(url)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getOnchainSyncedFolder(wallet: WatchOnlyWallet, completion: @escaping (Snapshot?) -> Void) {
        let folderType = FolderType.organized // TODO: support curated as well
        let take = 20 // TODO: paginate through all folders
        let skip = 0
        let attestationType: AttestationType? = nil // TODO: get them all
        
        let url = URL(string: "\(URL.easScanBase)/graphql")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let query = query(attester: wallet.address, folderType: folderType, take: take, skip: skip, attestationType: attestationType)
        guard let data = try? JSONSerialization.data(withJSONObject: query) else { return }
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            if let data = data, let attestationResponse = try? JSONDecoder().decode(AttestationResponse.self, from: data), let cid = attestationResponse.cid {
                if !Defaults.isKnownCid(cid, wallet: wallet) {
                    getSyncedFolderFromIpfs(cid: cid, completion: completion)
                }
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    private static func getSyncedFolderFromIpfs(cid: String, retryCount: Int = 0, completion: @escaping (Snapshot?) -> Void) {
        guard let url = URL(string: URL.ipfsGateway + cid) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, var snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) {
                snapshot.cid = cid
                completion(snapshot)
            } else {
                if retryCount < 3 {
                    FileDownloader.queue.asyncAfter(deadline: .now() + .seconds(retryCount + 1)) {
                        getSyncedFolderFromIpfs(cid: cid, retryCount: retryCount + 1, completion: completion)
                    }
                } else {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    
    private static func makeFoldersSnapshot(wallet: WatchOnlyWallet) -> Snapshot? {
        guard let url = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) else { return nil }
        let folders = foldersToSync(url: url)
        let snapshot = Snapshot(folders: folders, uuid: UUID().uuidString)
        return snapshot
    }
    
    private static func foldersToSync(url: URL) -> [Folder] {
        let fileManager = FileManager.default
        var folders = [Folder]()
        if let rootContents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil) {
            for item in rootContents {
                if item.hasDirectoryPath && item.lastPathComponent != ".nft" {
                    let tokens = tokensInFolder(url: item)
                    let folder = Folder(name: item.lastPathComponent, tokens: tokens, description: nil, cover: nil)
                    folders.append(folder)
                }
            }
        }
        return folders
    }
    
    private static func tokensInFolder(url: URL) -> [Token] {
        let fileManager = FileManager.default
        var tokens = [Token]()
        if let folderContents = try? fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            for content in folderContents {
                if content.hasDirectoryPath {
                    let deepTokens = tokensInFolder(url: content)
                    tokens.append(contentsOf: deepTokens)
                } else if let metadata = MetadataStorage.minimalMetadata(filePath: content.path) {
                    let token = Token(id: metadata.tokenId, address: metadata.collectionAddress, chainId: String(metadata.network.rawValue), comment: nil)
                    tokens.append(token)
                }
            }
        }
        return tokens
    }
    
    private static func query(attester: String, folderType: FolderType, take: Int, skip: Int, attestationType: AttestationType?) -> [String: Any] {
        // TODO: use attestationType value
        // TODO: batch query edits and created folders
        
        let query: [String: Any] = [
            "query": """
                query Attestation {
                    attestations(
                            take: \(take),
                            skip: \(skip),
                            orderBy: { timeCreated: desc },
                            where: {
                                schemaId: { equals: "\(URL.attestationSchemaId)" },
                                attester: { equals: "\(attester)" },
                                refUID: { equals: "0x0000000000000000000000000000000000000000000000000000000000000000" },
                                revoked: { equals: false },
                                data: { startsWith: "\(folderType.dataPrefix)"}
                            }
                        ) {
                            decodedDataJson
                            refUID
                            id
                        }
                }
            """,
            "variables": [:]
        ]
        
        let editsQuery: [String: Any] = [
            "query": """
                query Attestation {
                    attestations(
                            take: \(take),
                            skip: \(skip),
                            orderBy: { timeCreated: desc },
                            where: {
                                schemaId: { equals: "\(URL.attestationSchemaId)" },
                                attester: { equals: "\(attester)" },
                                refUID: { notIn: "0x0000000000000000000000000000000000000000000000000000000000000000" },
                                revoked: { equals: false },
                            },
                            distinct: [refUID]
                        ) {
                            decodedDataJson
                            refUID
                            id
                        }
                }
            """,
            "variables": [:]
        ]
        
        return query
    }
    
}
