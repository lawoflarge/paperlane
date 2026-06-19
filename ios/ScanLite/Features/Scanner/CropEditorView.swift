import SwiftUI

/// Manual crop: drag the four corners over the page, then apply a perspective
/// correction (free). The fix for the market's #1 complaint — auto-crop clipping
/// an edge with no override. Operates on one image, returns the corrected image.
struct CropEditorView: View {
    let image: UIImage
    var onApply: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var quad = CropGeometry.full

    private enum Corner: CaseIterable { case tl, tr, br, bl }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let frame = Self.fittedRect(imageSize: image.size, container: geo.size)
                ZStack(alignment: .topLeading) {
                    Color.black
                    Image(uiImage: image).resizable().scaledToFit()
                    quadOutline(in: frame)
                    ForEach(Array(Corner.allCases.enumerated()), id: \.offset) { _, corner in
                        handle(corner, in: frame)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Adjust crop")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply(PerspectiveCorrector().correct(image, quad: CropGeometry.clamped(quad)))
                        dismiss()
                    }.fontWeight(.semibold)
                }
                ToolbarItem(placement: .bottomBar) {
                    Button { quad = CropGeometry.full } label: { Label("Reset", systemImage: "arrow.counterclockwise") }
                }
            }
        }
    }

    private func corner(_ c: Corner) -> CGPoint {
        switch c {
        case .tl: return quad.topLeft
        case .tr: return quad.topRight
        case .br: return quad.bottomRight
        case .bl: return quad.bottomLeft
        }
    }

    private func setCorner(_ c: Corner, _ p: CGPoint) {
        switch c {
        case .tl: quad.topLeft = p
        case .tr: quad.topRight = p
        case .br: quad.bottomRight = p
        case .bl: quad.bottomLeft = p
        }
    }

    private func screen(_ n: CGPoint, in frame: CGRect) -> CGPoint {
        CGPoint(x: frame.minX + n.x * frame.width, y: frame.minY + n.y * frame.height)
    }

    private func quadOutline(in frame: CGRect) -> some View {
        Path { path in
            path.move(to: screen(quad.topLeft, in: frame))
            path.addLine(to: screen(quad.topRight, in: frame))
            path.addLine(to: screen(quad.bottomRight, in: frame))
            path.addLine(to: screen(quad.bottomLeft, in: frame))
            path.closeSubpath()
        }
        .stroke(PaperTheme.accent, lineWidth: 2)
    }

    private func handle(_ c: Corner, in frame: CGRect) -> some View {
        Circle()
            .fill(PaperTheme.accent)
            .frame(width: 22, height: 22)
            .overlay(Circle().stroke(.white, lineWidth: 2))
            .position(screen(corner(c), in: frame))
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { value in
                    guard frame.width > 0, frame.height > 0 else { return }
                    let nx = min(max((value.location.x - frame.minX) / frame.width, 0), 1)
                    let ny = min(max((value.location.y - frame.minY) / frame.height, 0), 1)
                    setCorner(c, CGPoint(x: nx, y: ny))
                }
            )
    }

    /// Where a scaledToFit image actually sits inside the container.
    static func fittedRect(imageSize: CGSize, container: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return CGRect(origin: .zero, size: container) }
        let scale = min(container.width / imageSize.width, container.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(x: (container.width - size.width) / 2,
                      y: (container.height - size.height) / 2,
                      width: size.width, height: size.height)
    }
}
