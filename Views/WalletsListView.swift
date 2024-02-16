// ∅ nft-folder-macos 2024

import Cocoa
import SwiftUI

struct WalletsListView: View {
    
    @State private var isWaiting = false
    @State private var showAddWalletPopup: Bool
    @State private var showSettingsPopup = false
    @State private var newWalletAddress = ""
    @State private var wallets = WalletsService.shared.wallets
    
    init(showAddWalletPopup: Bool) {
        self.showAddWalletPopup = showAddWalletPopup
    }
    
    var body: some View {
        Group {
            if wallets.isEmpty {
                Button(Strings.addWallet, action: {
                    showAddWalletPopup = true
                }).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section(header: Text(Strings.wallets).font(.system(size: 36, weight: .bold)).foregroundColor(.primary)) {
                        ForEach(wallets, id: \.self) { wallet in
                            HStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        WalletImageView(wallet: wallet)
                                    )
                                Text(wallet.listDisplayName).font(.system(size: 15, weight: .medium))
                                Spacer()
                            }
                            .contentShape(Rectangle()).onTapGesture {
                                openFolderForWallet(wallet)
                            }
                            .contextMenu {
                                Button(Strings.remove, action: {
                                    WalletsService.shared.removeWallet(wallet)
                                    if let path = URL.nftDirectory?.path {
                                        let pathToRemove = path + "/" + wallet.folderDisplayName
                                        try? FileManager.default.removeItem(atPath: pathToRemove)
                                    }
                                    updateDisplayedWallets()
                                })
                            }
                        }
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
        }.sheet(isPresented: $showAddWalletPopup) {
            VStack {
                Text(Strings.addWallet).fontWeight(.medium)
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
            }.frame(width: 230)
                .padding()
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
            NSApplication.shared.windows.forEach { $0.close() }
        }).frame(height: 36).offset(CGSize(width: 0, height: -6)).keyboardShortcut(.defaultAction).buttonStyle(LinkButtonStyle())
    }
    
    private func openFolderForWallet(_ wallet: WatchOnlyWallet) {
        if let nftDirectory = URL.nftDirectory(wallet: wallet, createIfDoesNotExist: true) {
            NSWorkspace.shared.open(nftDirectory)
        }
        NSApplication.shared.windows.forEach { $0.close() }
    }
    
    private func addWallet() {
        isWaiting = true
        WalletsService.shared.resolveENS(newWalletAddress) { result in
            if case .success(let response) = result {
                if showAddWalletPopup {
                    let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar)
                    WalletsService.shared.addWallet(wallet)
                    FolderIcon.set(for: wallet)
                    updateDisplayedWallets()
                    AllDownloadsManager.shared.syncNewWallet(wallet: wallet)
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
    }
    
}
