// ∅ 2025 lil org

import SwiftUI
import Combine

struct CollectionsView: View {
    
    @State private var showSettingsPopup = false
    @State private var suggestedItems = TokenGenerator.allGenerativeSuggestedItems
    @State private var didAppear = false
    @State private var showMorePreferences = false
    @State private var selectedConfig: PlayerWindowConfig?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    createGrid().frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Consts.noggles)
            .toolbar {
                Menu {
                    Text(Strings.sendFeedback)
                    Button(Strings.warpcast, action: { UIApplication.shared.open(URL.warpcast) })
                    Button(Strings.github, action: { UIApplication.shared.open(URL.github) })
                    Button(Strings.zora, action: { UIApplication.shared.open(URL.zora) })
                    Button(Strings.mail, action: { UIApplication.shared.open(URL.mail) })
                    Button(Strings.x, action: { UIApplication.shared.open(URL.x) })
                } label: {
                    Images.preferences
                }
                
                Button(action: {
                    showRandomPlayer()
                }) {
                    Images.shuffle
                }
            }
        }
        .fullScreenCover(item: $selectedConfig) { config in
            PlayerView(config: config).persistentSystemOverlays(.hidden)
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
    
    private func createGrid() -> some View {
        let gridLayout = [GridItem(.adaptive(minimum: 100), spacing: 0)]
        let grid = LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 0) {
            ForEach(suggestedItems) { item in
                Button(action: {
                    didSelectSuggestedItem(item)
                }) {
                    ZStack {
                        Image(item.id)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .aspectRatio(1, contentMode: .fill)
                            .contentShape(Rectangle())
                        VStack {
                            Spacer()
                            gridItemText(item.name) {
                                didSelectSuggestedItem(item)
                            }
                        }
                    }
                }.aspectRatio(1, contentMode: .fit).contextMenu { suggestedItemContextMenu(item: item) }
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
            Button(Strings.play, action: {
                didSelectSuggestedItem(item)
            })
        }
    }
    
    private func didSelectSuggestedItem(_ item: SuggestedItem) {
        selectedConfig = PlayerWindowConfig(initialItemId: item.id)
    }
    
    private func showRandomPlayer() {
        selectedConfig = PlayerWindowConfig(initialItemId: nil)
    }
    
}
