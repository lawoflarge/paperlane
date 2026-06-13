import SwiftUI
import UIKit

/// Procedural paper-fiber grain, generated once and tiled. Asset-free; adapts its
/// blend mode to the color scheme so every surface reads as paper, not glass.
enum PaperGrainTexture {
    static let image: UIImage = {
        let size = CGSize(width: 140, height: 140)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            for _ in 0..<2200 {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                let alpha = CGFloat.random(in: 0.015...0.05)
                UIColor(white: Bool.random() ? 0 : 1, alpha: alpha).setFill()
                ctx.fill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
    }()
}

struct PaperGrainModifier: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    func body(content: Content) -> some View {
        content.overlay {
            Image(uiImage: PaperGrainTexture.image)
                .resizable(resizingMode: .tile)
                .blendMode(scheme == .dark ? .screen : .multiply)
                .opacity(0.55)
                .allowsHitTesting(false)
                .ignoresSafeArea()
        }
    }
}

extension View {
    func paperGrain() -> some View { modifier(PaperGrainModifier()) }
}
