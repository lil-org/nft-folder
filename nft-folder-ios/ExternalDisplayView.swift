// ∅ 2025 lil org

import SwiftUI

func updateExternalDisplayToken(_ token: GeneratedToken) {
    ExternalDisplayManager.shared.currentToken = token
}

struct ExternalDisplayView: View {
    
    @ObservedObject private var externalDisplayManager = ExternalDisplayManager.shared
    
    var body: some View {
        VStack {
            Text(Strings.lilOrgLinkWithEmojis).font(.largeTitle).padding()
            Text(externalDisplayManager.currentToken.displayName).font(.headline).padding()
        }
    }
    
}

private class ExternalDisplayManager: ObservableObject {
    
    static let shared = ExternalDisplayManager()
    
    @Published var currentToken = GeneratedToken.empty
    
}
