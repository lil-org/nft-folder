// ∅ 2025 lil org

import SwiftUI
import Combine

struct VisionCollectionsView: View {
    
    @Environment(\.openWindow) private var openWindow
    
    @State private var showSettingsPopup = false
    @State private var suggestedItems = TokenGenerator.allGenerativeSuggestedItems
    @State private var didAppear = false
    @State private var showMorePreferences = false
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Spacer()
            }
            HStack {
                Spacer()
                Menu {
                    Text(Strings.sendFeedback)
                    Button(Strings.farcaster, action: { UIApplication.shared.open(URL.farcaster) })
                    Button(Strings.github, action: { UIApplication.shared.open(URL.github) })
                    Button(Strings.mail, action: { UIApplication.shared.open(URL.mail) })
                    Button(Strings.x, action: { UIApplication.shared.open(URL.x) })
                    Divider()
                    Button(Strings.rateOnTheAppStore) { UIApplication.shared.open(URL.writeAppStoreReview) }
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
        .frame(height: 42).padding(.horizontal).padding(.top, 8)
        ScrollView {
            createGrid().frame(maxWidth: .infinity)
        }
    }
    
    private func createGrid() -> some View {
        let gridLayout = [GridItem(.adaptive(minimum: 150), spacing: 0)]
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
            Text(text).font(.system(size: 15, weight: .regular)).lineLimit(2)
                .foregroundColor(.white)
                .padding(.horizontal, 1)
                .background(Color.black.opacity(0.7)).cornerRadius(3)
                .multilineTextAlignment(.leading)
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
        openWindow(value: VisionPlayerWindowConfig(initialItemId: item.id))
    }

    private func showRandomPlayer() {
        openWindow(value: VisionPlayerWindowConfig(initialItemId: nil))
    }
    
}
