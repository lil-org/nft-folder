// ∅ nft-folder 2024

import Cocoa
import SwiftUI

struct WalletsListView: View {
    
    @State private var hoveringOverAddress: String? = nil
    
    @State private var isWaiting = false
    @State private var showAddWalletPopup: Bool
    @State private var showSettingsPopup = false
    @State private var newWalletAddress = ""
    @State private var wallets = WalletsService.shared.wallets.first != nil ? [WalletsService.shared.wallets.first!] : [] // TODO: tmp, make a proper pagination
    @State private var downloadsStatuses = AllDownloadsManager.shared.statuses
    
    init(showAddWalletPopup: Bool) {
        self.showAddWalletPopup = showAddWalletPopup
    }
    
    var body: some View {
        Group {
            if wallets.isEmpty {
                Button(Strings.newFolder, action: {
                    showAddWalletPopup = true
                }).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    createGrid().frame(maxWidth: .infinity)
                }.background(Color(nsColor: .controlBackgroundColor))
                .toolbar {
                    ToolbarItemGroup {
                        Spacer()
                        Text(Consts.noggles).fontWeight(.semibold).frame(maxWidth: .infinity, alignment: .center)
                        Spacer()
                        Button(action: {
                            showSettingsPopup = true
                        }) {
                            Images.gearshape
                        }
                        
                        Button(action: {
                            showAddWalletPopup = true
                        }) {
                            Images.plus
                        }
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .downloadsStatusUpdate), perform: { _ in
            self.updateDisplayedWallets()
        }).sheet(isPresented: $showAddWalletPopup) {
            VStack {
                Text(Strings.newFolder).fontWeight(.medium)
                TextField(Strings.addressOrEns, text: $newWalletAddress)
                HStack {
                    Spacer()
                    Button(Strings.cancel, action: {
                        showAddWalletPopup = false
                        newWalletAddress = ""
                        isWaiting = false
                    })
                    
                    if isWaiting {
                        ProgressView().progressViewStyle(.circular).scaleEffect(0.5)
                    } else {
                        Button(Strings.ok, action: {
                            addWallet()
                        }).keyboardShortcut(.defaultAction)
                    }
                }
            }.frame(width: 230).padding()
        }.sheet(isPresented: $showSettingsPopup) {
            VStack {
                PreferencesView()
                HStack {
                    Spacer()
                    Button(Strings.ok, action: {
                        showSettingsPopup = false
                    }).keyboardShortcut(.defaultAction)
                }
            }.frame(width: 230).padding()
        }.onReceive(NotificationCenter.default.publisher(for: .walletsUpdate), perform: { _ in
            self.updateDisplayedWallets()
        })
        Button(Strings.openNftFolder, action: {
            if let nftDirectory = URL.nftDirectory {
                NSWorkspace.shared.open(nftDirectory)
            }
            Window.closeAll()
        }).frame(height: 36).offset(CGSize(width: 0, height: -6)).buttonStyle(LinkButtonStyle())
            .onAppear() {
                DispatchQueue.main.async {
                    self.updateDisplayedWallets()
                }
            }
    }
    
    private func openFolderForWallet(_ wallet: WatchOnlyWallet) {
        if let nftDirectory = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: true) {
            NSWorkspace.shared.open(nftDirectory)
        }
        AllDownloadsManager.shared.prioritizeDownloads(wallet: wallet)
    }
    
    private func hardReset(wallet: WatchOnlyWallet) {
        AllDownloadsManager.shared.stopDownloads(wallet: wallet)
        if let nftDirectory = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false) {
            let fileManager = FileManager.default
            try? fileManager.removeItem(at: nftDirectory)
            Defaults.cleanupForWallet(wallet)
            if let _ = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: true) {
                FolderIcon.set(for: wallet)
                AllDownloadsManager.shared.startDownloads(wallet: wallet)
                WalletsService.shared.checkIfCollection(wallet: wallet)
            }
        }
    }
    
    private func createGrid() -> some View {
        let gridLayout = [GridItem(.adaptive(minimum: 100), spacing: 1)]
        let grid = LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 1) {
            ForEach(wallets.indices, id: \.self) { index in
                item(for: wallets[index])
            }
        }
        return grid
    }
    
    func item(for wallet: WatchOnlyWallet) -> some View {
        let status = downloadsStatuses[wallet] ?? .notDownloading
        let color = hoveringOverAddress == wallet.address ? wallet.placeholderColor.opacity(0.69) : wallet.placeholderColor
        return Rectangle().aspectRatio(1, contentMode: .fit).overlay(ClickHandler { openFolderForWallet(wallet) }).foregroundStyle(color).contextMenu {
            Text(wallet.listDisplayName)
            Divider()
            switch status {
            case .downloading:
                Button(Strings.pause, action: {
                    AllDownloadsManager.shared.stopDownloads(wallet: wallet)
                })
            case .notDownloading:
                Button(Strings.sync, action: {
                    AllDownloadsManager.shared.startDownloads(wallet: wallet)
                })
            }
            Divider()
            Button(Strings.viewinFinder, action: {
                openFolderForWallet(wallet)
            })
            Button(Strings.viewOnZora, action: {
                if let galleryURL = NftGallery.zora.url(wallet: wallet) {
                    DispatchQueue.main.async { NSWorkspace.shared.open(galleryURL) }
                }
            })
            Button(Strings.viewOnOpensea, action: {
                if let galleryURL = NftGallery.opensea.url(wallet: wallet) {
                    DispatchQueue.main.async { NSWorkspace.shared.open(galleryURL) }
                }
            })
            if wallet.collections == nil {
                Divider()
                Button(Strings.pushCustomFolders, action: {
                    confirmFoldersPush(wallet: wallet)
                })
            }
            Divider()
            Button(Strings.hardReset, action: {
                hardReset(wallet: wallet)
            })
            Button(Strings.removeFolder, action: {
                WalletsService.shared.removeWallet(wallet)
                AllDownloadsManager.shared.stopDownloads(wallet: wallet)
                if let path = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: false)?.path {
                    try? FileManager.default.removeItem(atPath: path)
                }
                updateDisplayedWallets()
            })
        }.onHover { hovering in
            if hovering {
                hoveringOverAddress = wallet.address
            } else {
                hoveringOverAddress = nil
            }
        }
    }
    
    // TODO: reimplement within item and deprecate
    func oldItem(wallet: WatchOnlyWallet) -> some View {
        let status = downloadsStatuses[wallet] ?? .notDownloading
        return HStack(spacing: 0) {
            HStack {
                if wallet.collections == nil {
                    Circle().frame(width: 23, height: 23).foregroundStyle(wallet.placeholderColor).overlay(WalletImageView(wallet: wallet))
                }
                Text(wallet.listDisplayName).font(.system(size: 15, weight: .regular))
                Spacer()
            }.frame(height: 32).overlay(ClickHandler { openFolderForWallet(wallet) })
            Button(action: {
                switch status {
                case .downloading:
                    AllDownloadsManager.shared.stopDownloads(wallet: wallet)
                case .notDownloading:
                    AllDownloadsManager.shared.startDownloads(wallet: wallet)
                }
            }) {
                Spacer().frame(width: 4)
                ZStack {
                    Color.clear
                    switch status {
                    case .downloading:
                        Images.pause
                    case .notDownloading:
                        Images.sync
                    }
                }.frame(width: 10)
                Spacer()
            }.buttonStyle(BorderlessButtonStyle()).foregroundStyle(.tertiary).opacity(0.8)
        }
    }
    
    private func confirmFoldersPush(wallet: WatchOnlyWallet) {
        Alerts.showConfirmation(message: Strings.pushCustomFolders + "?", text: wallet.folderDisplayName) { confirmed in
            guard confirmed else { return }
            FolderSyncService.pushCustomFolders(wallet: wallet) { url in
                if let url = url {
                    NSWorkspace.shared.open(url)
                } else {
                    Alerts.showSomethingWentWrong()
                }
            }
        }
    }
    
    private func addWallet() {
        isWaiting = true
        WalletsService.shared.resolveENS(newWalletAddress) { result in
            if case .success(let response) = result {
                if showAddWalletPopup {
                    let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar, collections: nil)
                    WalletsService.shared.addWallet(wallet)
                    FolderIcon.set(for: wallet)
                    updateDisplayedWallets()
                    AllDownloadsManager.shared.startDownloads(wallet: wallet)
                }
                showAddWalletPopup = false
                newWalletAddress = ""
                isWaiting = false
            } else {
                isWaiting = false
            }
        }
    }
    
    private func updateDisplayedWallets() {
        wallets = WalletsService.shared.sortedWallets
        downloadsStatuses = AllDownloadsManager.shared.statuses
    }
    
}

// TODO: use it or deprecate it
struct WalletDropDelegate: DropDelegate {
    
    private let itemType = "public.text"
    
    @Binding var wallets: [WatchOnlyWallet]
    
    func performDrop(info: DropInfo) -> Bool {
        guard info.hasItemsConforming(to: [itemType]) else {
            return false
        }
        
        let providers = info.itemProviders(for: [itemType])
        for provider in providers {
            provider.loadItem(forTypeIdentifier: itemType, options: nil) { (item, error) in
                guard let data = item as? Data, let address = String(data: data, encoding: .utf8) else {
                    return
                }
                
                DispatchQueue.main.async {
                    print(address)
                    // TODO: update model
                }
            }
        }
        
        return false // TODO: enable when it's ready
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [itemType])
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
}
