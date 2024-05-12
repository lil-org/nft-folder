// ∅ nft-folder 2024

import Cocoa
import SwiftUI

struct WalletsListView: View {
    
    @State private var isWaiting = false
    @State private var showAddWalletPopup: Bool
    @State private var showSettingsPopup = false
    @State private var newWalletAddress = ""
    @State private var wallets = WalletsService.shared.sortedWallets
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
                GeometryReader { geometry in
                    ScrollView {
                        generateContent(in: geometry).frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .toolbar {
                    ToolbarItemGroup {
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
    }
    
    // TODO: reimplement reordering
    
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
            if let _ = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: true) {
                FolderIcon.set(for: wallet)
                AllDownloadsManager.shared.startDownloads(wallet: wallet)
                WalletsService.shared.checkIfCollection(wallet: wallet)
            }
        }
    }
    
    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(wallets, id: \.self) { wallet in
                item(for: wallet)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if wallet == wallets.last {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if wallet == wallets.last {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
    
    func item(for wallet: WatchOnlyWallet) -> some View {
        let status = downloadsStatuses[wallet] ?? .notDownloading
        return HStack {
            Group {
                Spacer().frame(width: 7)
                if wallet.collections == nil {
                    Circle().frame(width: 15, height: 15).foregroundStyle(.tertiary).overlay(WalletImageView(wallet: wallet))
                }
                Text(wallet.listDisplayName).font(.system(size: 15, weight: .regular))
            }.overlay(ClickHandler { openFolderForWallet(wallet) })
            switch status {
            case .downloading:
                Button(action: {
                    AllDownloadsManager.shared.stopDownloads(wallet: wallet)
                }) {
                    Images.pause
                }
                .buttonStyle(BorderlessButtonStyle()).frame(width: 10)
            case .notDownloading:
                Button(action: {
                    AllDownloadsManager.shared.startDownloads(wallet: wallet)
                }) {
                    Images.sync
                }.buttonStyle(BorderlessButtonStyle()).frame(width: 10).foregroundStyle(.tertiary)
            }
            Spacer().frame(width: 7)
        }.frame(height: 23).background(Color.gray.opacity(0.1)).cornerRadius(5)
            .contextMenu {
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
                    openFolderForWallet(wallet)
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
