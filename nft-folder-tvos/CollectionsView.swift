// ∅ nft-folder 2024

import SwiftUI
import Combine

struct CollectionsView: View {
    
    @State private var suggestedItems = TokenGenerator.allGenerativeSuggestedItems
    
    var body: some View {
        NavigationView {
            ScrollView {
                createGrid().frame(maxWidth: .infinity)
            }.navigationTitle(Consts.noggles)
        }
    }
    
    private func createGrid() -> some View {
        let gridLayout = [GridItem(.adaptive(minimum: 170), spacing: 0)]
        let grid = LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 0) {
            ForEach(suggestedItems) { item in
                ZStack {
                    Button(action: {
                        didSelectSuggestedItem(item)
                    }) {
                        Image(item.id)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .aspectRatio(1, contentMode: .fill)
                            .contentShape(Rectangle())
                    }.aspectRatio(1, contentMode: .fit)
                    VStack {
                        Spacer()
                        gridItemText(item.name)
                    }
                }
                .contextMenu { suggestedItemContextMenu(item: item) }
            }
        }
        return grid
    }
    
    private func gridItemText(_ text: String) -> some View {
        HStack {
            Text(text).font(.system(size: 15, weight: .regular)).lineLimit(2)
                .foregroundColor(.white)
                .padding(.horizontal, 1)
                .background(Color.black.opacity(0.7)).cornerRadius(3)
                .padding(.leading, 4).padding(.bottom, 3)
            Spacer()
        }
    }
    
    private func suggestedItemContextMenu(item: SuggestedItem) -> some View {
        Group {
            Text(item.name)
            Divider()
            Button(Strings.play, action: {
                didSelectSuggestedItem(item)
            })
        }
    }
    
    private func didSelectSuggestedItem(_ item: SuggestedItem) {
        // TODO: implement
    }
    
    private func showRandomPlayer() {
        // TODO: implement
    }
    
}

