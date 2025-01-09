import SwiftUI
import Combine

struct MobileCollectionsView: View {
    @State private var showSettingsPopup = false
    @State private var suggestedItems = TokenGenerator.allGenerativeSuggestedItems
    @State private var didAppear = false
    @State private var showMorePreferences = false
    @State private var selectedConfig: MobilePlayerConfig?
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    ScrollView {
                        ZStack {
                            createGrid().frame(maxWidth: .infinity)
                            PipPlaceholderOverlay()
                                .frame(width: 1, height: 1)
                                .position(x: 0, y: 0)
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(Consts.noggles)
                .toolbar {
                    Menu {
                        Text(Strings.sendFeedback)
                        Button(Strings.warpcast) { UIApplication.shared.open(URL.warpcast) }
                        Button(Strings.github) { UIApplication.shared.open(URL.github) }
                        Button(Strings.zora) { UIApplication.shared.open(URL.zora) }
                        Button(Strings.mail) { UIApplication.shared.open(URL.mail) }
                        Button(Strings.x) { UIApplication.shared.open(URL.x) }
                    } label: {
                        Images.preferences
                    }
                    Button { showRandomPlayer() } label: {
                        Images.shuffle
                    }
                }
            }
            if let _ = selectedConfig {
                MobilePlayerView(config: $selectedConfig)
                    .persistentSystemOverlays(.hidden)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: selectedConfig)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name.restoreMinimizedPip)) { notification in
            if let token = notification.object as? GeneratedToken, selectedConfig == nil {
                selectedConfig = MobilePlayerConfig(initialItemId: nil, specificToken: token)
            }
        }
    }
    
    private func createGrid() -> some View {
        let gridLayout = [GridItem(.adaptive(minimum: UIDevice.current.userInterfaceIdiom == .pad ? 130 : 100), spacing: 0)]
        return LazyVGrid(columns: gridLayout, alignment: .leading, spacing: 0) {
            ForEach(suggestedItems) { item in
                Button {
                    didSelectSuggestedItem(item)
                } label: {
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
                }
                .aspectRatio(1, contentMode: .fit)
                .contextMenu { suggestedItemContextMenu(item: item) }
            }
        }
    }
    
    private func gridItemText(_ text: String, onTap: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
                .font(.system(size: 10, weight: .regular))
                .lineLimit(2)
                .foregroundColor(.white)
                .padding(.horizontal, 1)
                .background(Color.black.opacity(0.7))
                .cornerRadius(3)
                .padding(.leading, 4)
                .padding(.bottom, 3)
                .onTapGesture { onTap() }
            Spacer()
        }
    }
    private func suggestedItemContextMenu(item: SuggestedItem) -> some View {
        Group {
            Text(item.name)
            Button(action: {
                didSelectSuggestedItem(item)
            }) {
                HStack {
                    Images.play
                    Text(Strings.play)
                }
            }
            Button(action: {
                didSelectPip(item)
            }) {
                HStack {
                    Images.pip
                    Text(Strings.pip)
                }
            }
        }
    }
    private func didSelectPip(_ item: SuggestedItem) {
        let token = TokenGenerator.generateRandomToken(specificCollectionId: item.id, notTokenId: nil)
        NotificationCenter.default.post(name: Notification.Name.togglePip, object: token)
    }
    
    private func didSelectSuggestedItem(_ item: SuggestedItem) {
        selectedConfig = MobilePlayerConfig(initialItemId: item.id)
    }
    
    private func showRandomPlayer() {
        selectedConfig = MobilePlayerConfig(initialItemId: nil)
    }
}
