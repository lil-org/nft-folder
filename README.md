# nft-folder

### [folder.lil.org](https://folder.lil.org)

![1](https://github.com/lil-org/nft-folder-macos/assets/7680193/7ea5a8cf-f2d6-4631-aba4-0bbab41a4467)

## nft folders + ethereum attestation service

### 1️⃣ upload `SyncedFolder` json to ipfs
```swift
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

### 2️⃣ create attestation with `SyncedFolder` json ipfs cid
```swift
static func attestFolder(address: String, cid: String) -> URL? {
    let inputString = cid.toPaddedHexString()
    return URL(string: "\(easScanBase)/attestation/attestWithSchema/\(nftFolderAttestationSchema)#template=\(address)::0:false:\(inputString)")
}
```
https://base.easscan.org/attestation/attestWithSchema/0x39693b21ffe38b11da9ae29437c981de90e56ddb8606ead0c5460ba4a9f93880#template=0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE::0:false:0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003b6261666b7265696263696c78787136756a776f67787463737333347a347678627a736733357737726f6f3734767a6233767a676c666c33797162340000000000


### 3️⃣ get the latest attestation
```
curl --request POST \
    --header 'content-type: application/json' \
    --url 'https://base.easscan.org/graphql' \
    --data '{"query":"query Attestation {\n  attestations(\n    take: 1,\n    orderBy: { timeCreated: desc},\n    where: { schemaId: { equals: \"0x39693b21ffe38b11da9ae29437c981de90e56ddb8606ead0c5460ba4a9f93880\" }, recipient: { equals: \"0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE\" }, attester: { equals: \"0xE26067c76fdbe877F48b0a8400cf5Db8B47aF0fE\" } }\n  ) {\n    attester\n    recipient\n    decodedDataJson\n    timeCreated\n  }\n}","variables":{}}'
```

### 4️⃣ get json corresponding to the latest attestation
https://ipfs.decentralized-content.com/ipfs/bafkreids5ui7vb5uc5dkfu36uhtriy72nf4l7budx2ja3cewsul6wkpo7q

### 5️⃣ get nfts from an api of your choice
use `SyncedFolder` to display nfts in folders

## development
* run the xcode project
