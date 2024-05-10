// ∅ nft-folder 2024

import Foundation

struct Strings {
    
    static let toolbarItemToolTip = loc("click for nft menu")
    static let toolbarItemName = loc("nft")
    static let openFolderMenuItem = "☺︎ " + openNftFolder
    static let syncMenuItem = "⟳ " + loc("sync nfts")
    static let controlCenterMenuItem = "❒ " + loc("control center")
    static let newFolder = loc("new folder")
    static let removeFolder = "⨂ " + loc("remove folder")
    static let hardReset = "↯ " + loc("hard reset")
    static let viewOnOpensea = "⛵︎ " + loc("view on opensea")
    static let viewinFinder = "☺︎ " + loc("show in finder")
    static let viewOnZora = "☀︎ " + loc("view on zora")
    static let addressOrEns = loc("address or ens")
    static let cancel = loc("cancel")
    static let openNftFolder = loc("show in finder")
    static let ok = loc("ok")
    static let sync = "↻ " + loc("sync")
    static let pause = "❙❙ " + loc("pause")
    static let stopAllDownloads = "⏹ " + loc("stop all downloads")
    static let newFolderMenuItem = "+ " + newFolder
    static let didNotUpload = loc("did not upload")
    static let retry = loc("retry")
    static let nftFolder = loc("nft folder")
    static let nftInfo = loc("metadata")
    static let somethingWentWrong = loc("something went wrong")
    static let maxFileSize50mb = loc("max file size 50 mb")
    static let downloadGlb = loc("download .glb files")
    static let poweredByZoraApi = loc("powered by zora api")
    static let quit = loc("quit")
    static let hideFromHere = loc("hide from here")
    static let showInMenuBar = loc("show in menu bar")
    
    static let zora = "zora"
    static let opensea = "opensea"
    static let mintfun = "mint.fun"
    static let ens = "ENS"
    
    static let controlCenterFrameAutosaveName = "control center"
    
    private static func loc(_ string: String.LocalizationValue) -> String {
        return String(localized: string)
    }
    
}
