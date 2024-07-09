// ∅ nft-folder 2024

import SwiftUI

struct LocalHtmlView: View {
    
    @State private var backgroundColor: String = "white"
    @State private var colorHistory: [String] = []
    @State private var currentIndex = 0
    
    var body: some View {
        DesktopWebView(htmlContent: generateHtml(with: backgroundColor))
            .onAppear {
                let initialColor = generateRandomColor()
                backgroundColor = initialColor
                colorHistory.append(initialColor)
            }
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 200, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: goBack) {
                        Images.back
                    }
                    .disabled(currentIndex <= 0)
                }
                ToolbarItem(placement: .navigation) {
                    Button(action: goForward) {
                        Images.forward
                    }
                }
            }
    }
    
    private func generateHtml(with color: String) -> String {
        """
        <html>
        <head>
            <style>
                body { background-color: \(color); }
            </style>
        </head>
        <body>
        </body>
        </html>
        """
    }
    
    private func generateRandomColor() -> String {
        let red = Int.random(in: 0...255)
        let green = Int.random(in: 0...255)
        let blue = Int.random(in: 0...255)
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
    
    private func goBack() {
        if currentIndex > 0 {
            currentIndex -= 1
            backgroundColor = colorHistory[currentIndex]
        }
    }
    
    private func goForward() {
        if currentIndex < colorHistory.count - 1 {
            currentIndex += 1
            backgroundColor = colorHistory[currentIndex]
        } else {
            let newColor = generateRandomColor()
            colorHistory.append(newColor)
            currentIndex += 1
            backgroundColor = newColor
        }
    }
    
}
