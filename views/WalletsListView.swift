// nft-folder-macos 2023 ethistanbul

import Cocoa
import SwiftUI

struct WalletsListView: View {
    
    @State private var showAddWalletPopup = false
    @State private var newWalletAddress = ""
    
    private let wallets = WalletsService.shared.wallets
    
    var body: some View {
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
                            // TODO: implement
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
        .sheet(isPresented: $showAddWalletPopup) {
            VStack {
                Text("add a wallet").fontWeight(.medium)
                TextField("address or ens", text: $newWalletAddress)
                HStack {
                    Spacer()
                    Button("cancel", action: {
                        showAddWalletPopup = false
                    })
                    Button("ok", action: {
                        // TODO: add a wallet
                    })
                }
            }.frame(width: 320)
            .padding()
        }
    }
}
