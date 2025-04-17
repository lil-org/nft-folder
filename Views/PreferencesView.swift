// ∅ 2025 lil org

import SwiftUI

struct PreferencesView: View {
    
    @State private var maxFileSizeLimitPreference = !Defaults.unlimitedFileSize
    @State private var videoPreference = Defaults.downloadVideo
    @State private var audioPreference = Defaults.downloadAudio
    @State private var hasHiddenSuggestedItems = !Defaults.suggestedItemsToHide.isEmpty
    
    @State private var hoveringOverURL: URL? = nil
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Images.logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text(Strings.nftFolder)
                    .font(.system(size: 20))
            }.padding(.top, 4)
               
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .frame(height: 100)
                    .overlay(
                        VStack(alignment: .leading) {
                            Toggle(isOn: $maxFileSizeLimitPreference) {
                                Text(Strings.maxFileSize50mb)
                            }.onChange(of: maxFileSizeLimitPreference) { _, newValue in
                                Defaults.unlimitedFileSize = !newValue
                            }
                            
                            Toggle(isOn: $videoPreference) {
                                Text(Strings.downloadVideo)
                            }.onChange(of: videoPreference) { _, newValue in
                                Defaults.downloadVideo = newValue
                            }
                            
                            Toggle(isOn: $audioPreference) {
                                Text(Strings.downloadAudio)
                            }.onChange(of: audioPreference) { _, newValue in
                                Defaults.downloadAudio = newValue
                            }
                        }
                        .padding()
                    )
                    .padding(.horizontal).padding(.top)
            }
            HStack(spacing: 20) {
                ForEach(FooterLink.all, id: \.self) { link in
                    Link(destination: link.url) {
                        link.image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(hoveringOverURL == link.url ? .accentColor : .secondary).onHover { hovering in
                                if hovering {
                                    hoveringOverURL = link.url
                                } else {
                                    hoveringOverURL = nil
                                }
                            }
                    }
                }
            }.padding(.top).padding(.bottom)
        }
    }
    
}
