// ∅ 2025 lil org

import SwiftUI
import Combine

struct MobileCollectionsView: View {
    
    @State private var showSettingsPopup = false
    @State private var suggestedItems = TokenGenerator.allGenerativeSuggestedItems
    @State private var didAppear = false
    @State private var showMorePreferences = false
    @State private var selectedConfig: MobilePlayerConfig?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ZStack {
                        createGrid().frame(maxWidth: .infinity)
                        PipPlaceholderOverlay().frame(width: 1, height: 1).position(x: 0, y: 0)
                    }
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
            MobilePlayerView(config: config).persistentSystemOverlays(.hidden)
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.restoreMinimizedPip)) { notification in
            if let token = notification.object as? GeneratedToken, selectedConfig == nil {
                selectedConfig = MobilePlayerConfig(initialItemId: nil, specificToken: token)
            }
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
        selectedConfig = MobilePlayerConfig(initialItemId: item.id)
    }
    
    private func showRandomPlayer() {
        selectedConfig = MobilePlayerConfig(initialItemId: nil)
    }
    
}
