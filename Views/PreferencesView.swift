// ∅ nft-folder-macos 2024

import SwiftUI

struct PreferencesView: View {

    @State private var maxFileSizeLimitPreference = !Defaults.unlimitedFileSize
    @State private var glbPreference = Defaults.downloadGlb
    
    var body: some View {
        Form {
            Section {
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
            Spacer()
        }
    }
}
