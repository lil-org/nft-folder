# syncing custom nft folders

organize nfts into folders and see the same custom folders in zora, opensea, rainbow, etc.

what could be a good standard way to sync a custom folders structure?

proposal:

## nft folders + ethereum attestation service

### 1️⃣ upload `SyncedFolderSnapshot` json to ipfs
```swift
struct SyncedFolderSnapshot: Codable {
    
    let formatVersion: Int
    let uuid: String
    let nonce: Int
    let timestamp: Int
    let address: String
    let rootFolder: SyncedFolder
    
}

struct SyncedFolder: Codable {
    
    let name: String
    let nfts: [NftInSyncedFolder]
    let childrenFolders: [SyncedFolder]
    
}

struct NftInSyncedFolder: Codable {

    let chainId: String
    let tokenId: String
    let address: String
    
}

```

### 2️⃣ create an attestation with `SyncedFolderSnapshot` ipfs cid
```swift
static func attestFolder(address: String, cid: String) -> URL? {
    let inputString = cid.toPaddedHexString()
    return URL(string: "\(easScanBase)/attestation/attestWithSchema/\(nftFolderAttestationSchema)#template=\(address)::0:false:\(inputString)")
}
```
https://base.easscan.org/attestation/attestWithSchema/0x39693b21ffe38b11da9ae29437c981de90e56ddb8606ead0c5460ba4a9f93880#template=0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE::0:false:0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003b6261666b726569626437617376627864676d37746e746c676665636a736d743272686d6f78737a366176756d746175687068756e666872357461790000000000


### 3️⃣ get the latest attestation
using [easscan graphql api](https://docs.attest.org/docs/developer-tools/api)
```
curl --request POST \
    --header 'content-type: application/json' \
    --url 'https://base.easscan.org/graphql' \
    --data '{"query":"query Attestation {\n  attestations(\n    take: 1,\n    orderBy: { timeCreated: desc},\n    where: { schemaId: { equals: \"0x39693b21ffe38b11da9ae29437c981de90e56ddb8606ead0c5460ba4a9f93880\" }, recipient: { equals: \"0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE\" }, attester: { equals: \"0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE\" } }\n  ) {\n    attester\n    recipient\n    decodedDataJson\n    timeCreated\n  }\n}","variables":{}}'
```

### 4️⃣ get `SyncedFolderSnapshot` json corresponding to the latest attestation
https://ipfs.decentralized-content.com/ipfs/bafkreibd7asvbxdgm7tntlgfecjsmt2rhmoxsz6avumtauhphunfhr5tay

### 5️⃣ get nfts from an api of your choice
use `SyncedFolderSnapshot` to display nfts in folders
