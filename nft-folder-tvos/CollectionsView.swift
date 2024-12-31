// ∅ 2025 lil org

import SwiftUI
import Combine

struct CollectionsView: View {
    
    @State private var suggestedItems = TokenGenerator.allGenerativeSuggestedItems
    @State private var selectedItemId: String?
    @State private var isNavigatingToPlayer = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                createGrid()
            }
            .navigationTitle(Consts.noggles)
            .navigationBarItems(trailing: shuffleButton)
            .background(
                NavigationLink(destination: TvPlayerView(initialItemId: selectedItemId).edgesIgnoringSafeArea(.all), isActive: $isNavigatingToPlayer) {
                    EmptyView().hidden()
                }.hidden()
            )
        }
    }
    
    private var shuffleButton: some View {
        Button(action: showRandomPlayer) {
            Images.shuffle
        }.buttonStyle(PlainButtonStyle()).foregroundStyle(.tertiary)
    }
    
    private func createGrid() -> some View {
        let gridLayout = [GridItem(.adaptive(minimum: 230), spacing: 20)]
        let grid = LazyVGrid(columns: gridLayout, alignment: .center, spacing: 23) {
            ForEach(suggestedItems) { item in
                Button(action: {
                    didSelectSuggestedItem(item)
                }) {
                    VStack {
                        Image(item.id)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                        gridItemText(item.name)
                    }
                }
                .contextMenu { suggestedItemContextMenu(item: item) }
            }
        }
        .padding(.horizontal)
        return grid
    }
    
    private func gridItemText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .regular))
            .lineLimit(2)
            .foregroundColor(.white)
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.7))
            .cornerRadius(5)
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
        selectedItemId = item.id
        isNavigatingToPlayer = true
    }
    
    private func showRandomPlayer() {
        selectedItemId = suggestedItems.randomElement()?.id
        isNavigatingToPlayer = true
    }
    
}
