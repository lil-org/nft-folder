// nft-folder-macos 2023 ethistanbul

import Cocoa
import SwiftUI

struct WalletsListView: View {
    
    @State private var isWaiting = false
    @State private var showAddWalletPopup: Bool
    @State private var newWalletAddress = ""
    @State private var wallets = WalletsService.shared.wallets
    
    init(showAddWalletPopup: Bool) {
        self.showAddWalletPopup = showAddWalletPopup
    }
    
    var body: some View {
        Group {
            if wallets.isEmpty {
                Button("add a wallet", action: {
                    showAddWalletPopup = true
                }).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    Section(header: Text("wallets")) {
                        ForEach(wallets, id: \.self) { wallet in
                            HStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Image(systemName: "person.fill") // TODO: avatar or blockies
                                            .resizable()
                                            .scaledToFit()
                                            .clipShape(Circle())
                                    )
                                Text(wallet.displayName)
                            }
                            .contentShape(Rectangle())
                            .contextMenu {
                                Button("remove", action: {
                                    WalletsService.shared.removeWallet(wallet)
                                    updateDisplayedWallets()
                                })
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .confirmationAction) {
                        Spacer()
                        Button(action: {
                            showAddWalletPopup = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }.sheet(isPresented: $showAddWalletPopup) {
            VStack {
                Text("add a wallet").fontWeight(.medium)
                TextField("address or ens", text: $newWalletAddress)
                HStack {
                    Spacer()
                    Button("cancel", action: {
                        showAddWalletPopup = false
                        newWalletAddress = ""
                        isWaiting = false
                    })
                    
                    if isWaiting {
                        ProgressView().progressViewStyle(.circular).scaleEffect(0.5)
                    } else {
                        Button("ok", action: {
                            addWallet()
                        }).keyboardShortcut(.defaultAction)
                    }
                    
                    
                }
            }.frame(width: 320)
                .padding()
        }
        if !wallets.isEmpty {
            Button("show nft folder", action: {
                if let nftDirectory = URL.nftDirectory {
                    NSWorkspace.shared.open(nftDirectory)
                }
                NSApplication.shared.windows.forEach { $0.close() }
            }).frame(height: 36).offset(CGSize(width: 0, height: -6)).keyboardShortcut(.defaultAction)
        }
    }
    
    func addWallet() {
        isWaiting = true
        WalletsService.shared.resolveENS(newWalletAddress) { result in
            if case .success(let response) = result {
                if showAddWalletPopup {
                    let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar)
                    WalletsService.shared.addWallet(wallet)
                    updateDisplayedWallets()
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
