// ∅ nft-folder 2024

import Cocoa
import SwiftUI
import UniformTypeIdentifiers

struct WalletsListView: View {
    
    @State private var isWaiting = false
    @State private var showAddWalletPopup: Bool
    @State private var showSettingsPopup = false
    @State private var newWalletAddress = ""
    @State private var wallets = [WatchOnlyWallet]()
    @State private var suggestedItems = SuggestedItemsService.allItems
    @State private var didAppear = false
    @State private var downloadsStatuses = AllDownloadsManager.shared.statuses
    @State private var draggingIndex: Int? = nil
    @State private var currentDropDestination: Int? = nil
    
    init(showAddWalletPopup: Bool) {
        self.showAddWalletPopup = showAddWalletPopup
    }
    
    var body: some View {
        Group {
            if wallets.isEmpty && didAppear {
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
                            resolveEnsAndAddWallet()
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
                self.updateDisplayedWallets()
                didAppear = true
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
                if wallet.collections == nil {
                    WalletsService.shared.checkIfCollection(wallet: wallet)
                }
            }
        }
    }
    
    private func createGrid() -> some View {
        let gridLayout = [GridItem(.adaptive(minimum: 100), spacing: 0)]
        let grid = LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 0) {
            ForEach(wallets.indices, id: \.self) { index in
                item(for: wallets[index], index: index).onDrag {
                    self.draggingIndex = index
                    return NSItemProvider(object: String(wallets[index].address) as NSString)
                }
                .onDrop(of: [UTType.text], delegate: WalletDropDelegate(wallets: $wallets,
                                                                        sourceIndex: $draggingIndex,
                                                                        destinationIndex: Binding.constant(IndexSet(integer: index)),
                                                                        currentDropDestination: $currentDropDestination))
            }
            
            ForEach(suggestedItems) { item in
                ZStack {
                    Image(item.address).resizable().scaledToFill().clipped().aspectRatio(1, contentMode: .fit).contentShape(Rectangle())
                        .onTapGesture {
                            didSelectSuggestedItem(item)
                        }.overlay(FirstMouseView())
                    VStack {
                        Spacer()
                        gridItemText(item.name) {
                            didSelectSuggestedItem(item)
                        }
                    }
                }
            }
        }
        return grid
    }
    
    func item(for wallet: WatchOnlyWallet, index: Int) -> some View {
        let status = downloadsStatuses[wallet] ?? .notDownloading
        let isDestination = currentDropDestination == index
        let item = ZStack {
            WalletImageView(wallet: wallet)
                        .aspectRatio(1, contentMode: .fit).contentShape(Rectangle())
                        .border(isDestination ? Color.blue : Color.clear, width: 2)
                        .onTapGesture {
                            openFolderForWallet(wallet)
                        }
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Rectangle().foregroundColor(.clear).contentShape(Rectangle())
                        if status == .downloading {
                            Circle().frame(width: 27, height: 27).foregroundStyle(.regularMaterial)
                            Images.pause.foregroundStyle(.white).overlay(FirstMouseView())
                        } else {
                            Images.sync.shadow(color: .black, radius: 7).foregroundStyle(.white.opacity(0.77))
                        }
                    }
                    .frame(width: 34, height: 34)
                    .onTapGesture {
                        switch status {
                        case .downloading:
                            AllDownloadsManager.shared.stopDownloads(wallet: wallet)
                        case .notDownloading:
                            AllDownloadsManager.shared.startDownloads(wallet: wallet)
                        }
                    }
                }
                Spacer()
                gridItemText(wallet.listDisplayName) {
                    openFolderForWallet(wallet)
                }
            }
        }.contextMenu { walletContextMenu(wallet: wallet, status: status) }
        return item
    }
    
    private func gridItemText(_ text: String, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text).font(.system(size: 10, weight: .regular))
                .foregroundColor(.white)
                .padding(.horizontal, 1)
                .background(Color.black.opacity(0.7)).cornerRadius(3)
                .padding(.leading, 5).padding(.bottom, 3).onTapGesture {
                    onTap()
                }
            Spacer()
        }
    }
    
    private func walletContextMenu(wallet: WatchOnlyWallet, status: AllDownloadsManager.Status) -> some View {
        Group {
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
    
    private func didSelectSuggestedItem(_ item: SuggestedItem) {
        let wallet = WatchOnlyWallet(address: item.address, name: item.name, avatar: nil, collections: [CollectionInfo(name: item.name, network: item.network)])
        addWallet(wallet, skipCollectionCheck: true)
        openFolderForWallet(wallet)
        suggestedItems.removeAll(where: { item.id == $0.id })
        if let image = NSImage(named: item.address) {
            AvatarService.setAvatar(wallet: wallet, image: image)
        }
        SuggestedItemsService.doNotSuggestAnymore(item: item)
    }
    
    private func addWallet(_ wallet: WatchOnlyWallet, skipCollectionCheck: Bool) {
        WalletsService.shared.addWallet(wallet, skipCollectionCheck: skipCollectionCheck)
        FolderIcon.set(for: wallet)
        updateDisplayedWallets()
        AllDownloadsManager.shared.startDownloads(wallet: wallet)
    }
    
    private func resolveEnsAndAddWallet() {
        isWaiting = true
        WalletsService.shared.resolveENS(newWalletAddress) { result in
            if case .success(let response) = result {
                if showAddWalletPopup {
                    let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar, collections: nil)
                    addWallet(wallet, skipCollectionCheck: false)
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
        wallets = WalletsService.shared.wallets
        downloadsStatuses = AllDownloadsManager.shared.statuses
    }
    
}

struct WalletDropDelegate: DropDelegate {
    
    @Binding var wallets: [WatchOnlyWallet]
    @Binding var sourceIndex: Int?
    @Binding var destinationIndex: IndexSet
    @Binding var currentDropDestination: Int?
    
    func performDrop(info: DropInfo) -> Bool {
        guard let source = sourceIndex, let destination = destinationIndex.first else { return false }
        let finalDestination = source <= destination ? destination + 1 : destination
        wallets.move(fromOffsets: IndexSet(integer: source), toOffset: finalDestination)
        WalletsService.shared.updateWithWallets(wallets)
        return true
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [UTType.text])
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if sourceIndex != destinationIndex.first {
            currentDropDestination = destinationIndex.first
        }
        return DropProposal(operation: .move)
    }
    
    func dropExited(info: DropInfo) {
        if destinationIndex.first == currentDropDestination {
            currentDropDestination = nil
        }
    }
    
}
