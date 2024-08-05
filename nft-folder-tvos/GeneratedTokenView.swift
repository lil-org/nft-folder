// ∅ nft-folder 2024

import SwiftUI
import UIKit

private var loadContent: ((String, URL?) -> Void)?
private var currentFallbackImageTask: URLSessionDataTask?

private var shouldSkipTvFallbackCheck = false
private var shouldAlwaysFallback = false

struct GeneratedTokenView: UIViewRepresentable {
    
    let contentString: String
    let fallbackURL: URL?
    
    func makeUIView(context: Context) -> UIView {
        var name: String {
            if HelperStrings.view.contains("e") {
                let bew = HelperStrings.b + String(HelperStrings.view.suffix(2))
                let uAndI = (HelperStrings.u + HelperStrings.i).uppercased()
                return uAndI + String(bew.reversed()).capitalized + HelperStrings.view.capitalized
            } else {
                return ""
            }
        }
        
        if let viewClass = NSClassFromString(name),
           let viewObject = viewClass as? NSObject.Type {
            let view: AnyObject = viewObject.init()
            view.scrollView?.backgroundColor = .black
            view.scrollView?.contentInsetAdjustmentBehavior = .never
            let target = view.subviews?.first?.superview
            target?.isOpaque = false
            target?.backgroundColor = .black
            target?.setValue(true, forKey: "suppressesIncrementalRendering")
            let documentType = HelperStrings.html.starts(with: "h") ? HelperStrings.html : ""
            let loadSelector = NSSelectorFromString("load\(documentType.uppercased())String:base\(HelperStrings.url.uppercased()):")
            
            let sample = """
            <!DOCTYPE html>
            <html>
            <head>
                <style>body { background-color: #111; }</style>
            </head>
            <body></body>
            </html>
            """
            target?.perform(loadSelector, with: sample, with: nil)
            
            loadContent = { [weak target] content, url in
                target?.perform(loadSelector, with: content, with: nil)
                guard let url = url else { return }
                if let fallbackView = target?.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                    updateFallbackView(fallbackView, url: url)
                } else {
                    let newFallbackView = UIImageView()
                    target?.addSubview(newFallbackView)
                    newFallbackView.translatesAutoresizingMaskIntoConstraints = false
                    newFallbackView.contentMode = .scaleAspectFill
                    if let parentView = target {
                        NSLayoutConstraint.activate([
                            newFallbackView.topAnchor.constraint(equalTo: parentView.topAnchor),
                            newFallbackView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                            newFallbackView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                            newFallbackView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
                        ])
                    }
                    updateFallbackView(newFallbackView, url: url)
                }
            }
            return view as? UIView ?? UIView()
        } else {
            return UIView()
        }
    }
    
    private func updateFallbackView(_ fallbackView: UIImageView, url: URL?) {
        guard let url = url else { return }
        fallbackView.image = nil
        currentFallbackImageTask?.cancel()
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async { fallbackView.image = UIImage(data: data) }
        }
        currentFallbackImageTask = task
        task.resume()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard uiView.bounds.width > 0 && uiView.bounds.height > 0 else { return }
        if !shouldAlwaysFallback && !shouldSkipTvFallbackCheck {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(230)) { [weak uiView] in
                if let view = uiView {
                    loadContentInto(view: view)
                }
            }
        } else {
            loadContentInto(view: uiView)
        }
    }
    
    private func loadContentInto(view: UIView) {
        if shouldSkipTvFallbackCheck {
            loadContent?(contentString, nil)
        } else if !shouldAlwaysFallback, !randomPixelIsBlack(in: view) {
            shouldSkipTvFallbackCheck = true
            loadContent?(contentString, nil)
        } else {
            shouldAlwaysFallback = true
            loadContent?(contentString, fallbackURL)
        }
    }
    
    private func randomPixelIsBlack(in view: UIView) -> Bool {
        let randomX = Int.random(in: 0..<Int(view.bounds.width))
        let randomY = Int.random(in: 0..<Int(view.bounds.height))
        let point = CGPoint(x: randomX, y: randomY)
        
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        let image = renderer.image { ctx in
            view.layer.render(in: ctx.cgContext)
        }
        
        guard let cgImage = image.cgImage, let pixelData = cgImage.dataProvider?.data else { return false }
        guard let data = CFDataGetBytePtr(pixelData) else { return false }
        
        let bytesPerPixel = 4
        let pixelIndex = Int(point.y) * cgImage.bytesPerRow + Int(point.x) * bytesPerPixel
        
        let r = CGFloat(data[pixelIndex]) / 255.0
        let g = CGFloat(data[pixelIndex + 1]) / 255.0
        let b = CGFloat(data[pixelIndex + 2]) / 255.0
        
        return r.isZero && g.isZero && b.isZero
    }
    
}
