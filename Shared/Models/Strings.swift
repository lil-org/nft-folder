// ∅ nft-folder 2024

import Foundation

struct Strings {
    
    static let toolbarItemToolTip = loc("Click for NFT menu")
    static let toolbarItemName = loc("NFT")
    static let syncMenuItem = loc("Sync NFTs")
    static let controlCenterMenuItem = loc("Control Center") + "..."
    static let newFolder = loc("New Folder")
    static let removeFolder = loc("Remove Folder")
    static let hardReset = loc("Hard Reset")
    static let viewOnArtBlocks = loc("View on Art Blocks")
    static let viewOnOpensea = loc("View on OpenSea")
    static let viewinFinder = loc("Show in Finder")
    static let viewOnZora = loc("View on Zora")
    static let addressOrEns = loc("Address or ENS")
    static let cancel = loc("Cancel")
    static let ok = loc("OK")
    static let sync = loc("Sync")
    static let pause = loc("Pause")
    static let stopAllDownloads = loc("Stop Downloads")
    static let newFolderMenuItem = newFolder
    static let didNotUpload = loc("Did not upload")
    static let retry = loc("Retry")
    static let nftFolder = loc("nft folder")
    static let somethingWentWrong = loc("Something went wrong")
    static let maxFileSize50mb = loc("Max file size 50 MB")
    static let downloadGlb = loc("Download .glb files")
    static let hideFromHere = loc("Hide")
    static let showInMenuBar = loc("Show in menu bar")
    static let pushCustomFolders = loc("Save Folders Onchain")
    static let downloadVideo = loc("Download video")
    static let downloadAudio = loc("Download audio")
    static let restoreHiddenItems = loc("Restore Hidden Items")
    static let eraseAllContent = loc("Erase All Content")
    static let experimetalOfflineGeneration = loc("Offline generation is a new experimental feature")
    static let letUsKnowOfIssues = loc("Let us know of any issues.")
    
    static let zora = "Zora"
    static let opensea = "OpenSea"
    static let mintfun = "mint.fun"
    static let ens = "ENS"
    
    private static func loc(_ string: String.LocalizationValue) -> String {
        return String(localized: string)
    }
    
}
