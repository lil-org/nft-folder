// ∅ nft-folder 2024

import SwiftUI

struct PreferencesView: View {
    
    @State private var maxFileSizeLimitPreference = !Defaults.unlimitedFileSize
    @State private var glbPreference = Defaults.downloadGlb
    @State private var videoPreference = Defaults.downloadVideo
    @State private var audioPreference = Defaults.downloadAudio
    @State private var showInMenuBar = !Defaults.hideFromMenuBar
    
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
                    .frame(height: 150)
                    .overlay(
                        VStack(alignment: .leading) {
                            Toggle(isOn: $maxFileSizeLimitPreference) {
                                Text(Strings.maxFileSize50mb)
                            }.onChange(of: maxFileSizeLimitPreference) { newValue in
                                Defaults.unlimitedFileSize = !newValue
                            }
                            
                            Toggle(isOn: $glbPreference) {
                                Text(Strings.downloadGlb)
                            }.onChange(of: glbPreference) { newValue in
                                Defaults.downloadGlb = newValue
                            }
                            
                            Toggle(isOn: $videoPreference) {
                                Text(Strings.downloadVideo)
                            }.onChange(of: videoPreference) { newValue in
                                Defaults.downloadVideo = newValue
                            }
                            
                            Toggle(isOn: $audioPreference) {
                                Text(Strings.downloadAudio)
                            }.onChange(of: audioPreference) { newValue in
                                Defaults.downloadAudio = newValue
                            }
                            
                            Toggle(isOn: $showInMenuBar) {
                                Text(Strings.showInMenuBar)
                            }.onChange(of: showInMenuBar) { newValue in
                                Defaults.hideFromMenuBar = !newValue
                                if newValue {
                                    StatusBarItem.shared.showIfNeeded()
                                } else {
                                    StatusBarItem.shared.hideFromMenuBar()
                                }
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
