// nft-folder-macos 2023 ethistanbul

import Cocoa
import SwiftUI

struct WalletsListView: View {
    
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
                                    Defaults.removeWallet(wallet)
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
                    })
                    Button("ok", action: {
                        addWallet()
                    })
                }
            }.frame(width: 320)
                .padding()
        }
    }
    
    func addWallet() {
        WalletsService.shared.resolveENS(newWalletAddress) { result in
            if case .success(let response) = result {
                let wallet = WatchOnlyWallet(address: response.address, name: response.name, avatar: response.avatar)
                Defaults.addWallet(wallet)
                updateDisplayedWallets()
                showAddWalletPopup = false
                newWalletAddress = ""
            } else {
                // TODO: smth
            }
        }
    }
    
    private func updateDisplayedWallets() {
        wallets = WalletsService.shared.wallets
    }
    
}
