// ∅ nft-folder 2024

import SwiftUI
import Combine

struct CollectionsView: View {
    
    @Environment(\.openWindow) private var openWindow
    
    @State private var showSettingsPopup = false
    @State private var suggestedItems = TokenGenerator.allGenerativeSuggestedItems
    @State private var didAppear = false
    @State private var showMorePreferences = false
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Text(Consts.noggles)
                Spacer()
            }
            HStack {
                Spacer()
                Button(action: {
                    showRandomPlayer()
                }) {
                    Images.shuffle
                }
            }
        }
        .frame(height: 42).padding(.horizontal).padding(.top, 8)
        ScrollView {
            createGrid().frame(maxWidth: .infinity)
        }
    }
    
    private func createGrid() -> some View {
        let gridLayout = [GridItem(.adaptive(minimum: 100), spacing: 0)]
        let grid = LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 0) {
            ForEach(suggestedItems) { item in
                ZStack {
                    Image(item.id).resizable().scaledToFill().clipped().aspectRatio(1, contentMode: .fit).contentShape(Rectangle())
                        .onTapGesture {
                            didSelectSuggestedItem(item)
                        }
                    VStack {
                        Spacer()
                        gridItemText(item.name) {
                            didSelectSuggestedItem(item)
                        }
                    }
                }.contextMenu { suggestedItemContextMenu(item: item) }
            }
        }
        return grid
    }
    
    private func gridItemText(_ text: String, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text).font(.system(size: 10, weight: .regular)).lineLimit(2)
                .foregroundColor(.white)
                .padding(.horizontal, 1)
                .background(Color.black.opacity(0.7)).cornerRadius(3)
                .padding(.leading, 4).padding(.bottom, 3).onTapGesture {
                    onTap()
                }
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
        openWindow(value: PlayerWindowConfig(initialItemId: item.id))
    }

    private func showRandomPlayer() {
        openWindow(value: PlayerWindowConfig(initialItemId: nil))
    }
    
}
