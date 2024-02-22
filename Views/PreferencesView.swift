// ∅ nft-folder-macos 2024

import SwiftUI

struct PreferencesView: View {
    
    @State private var maxFileSizeLimitPreference = !Defaults.unlimitedFileSize
    @State private var glbPreference = Defaults.downloadGlb
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Images.logo
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text(Strings.nftFolder)
                    .font(.title)
                    .padding(.leading, 8).foregroundColor(.secondary)
            }
            .padding(.leading)
            
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .frame(height: 110)
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
                        }
                            .padding()
                    )
                    .padding()
            }
            
            
            VStack {
                VStack(alignment: .leading, spacing: 4) {
                    Link(destination: FooterLink.nounsURL) {
                        Text(Strings.noggles).font(.title3)
                    }.foregroundColor(.secondary)
                    Link(Strings.poweredByZoraApi, destination: FooterLink.zoraURL).foregroundColor(.secondary)
                }
                .padding()
                
                HStack(spacing: 20) {
                    ForEach(FooterLink.all, id: \.self) { link in
                        Link(destination: link.url) {
                            link.image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.bottom)
            }
        }
    }
    
}
