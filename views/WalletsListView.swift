// nft-folder-macos 2023 ethistanbul

import Cocoa
import SwiftUI

struct WalletsListView: View {
    
    private let wallets = WalletsService.shared.wallets
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("watchlist") ) {
                    ForEach(wallets, id: \.self) { wallet in
                        HStack {
                            Text(wallet.displayName)
                        }
                        .contentShape(Rectangle())
                    }
                }
                
            }
        }
    }
    
}
