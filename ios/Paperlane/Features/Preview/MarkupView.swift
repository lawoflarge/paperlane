import SwiftUI
import PencilKit

/// Draw a signature or annotate freely over a page, then flatten the drawing onto
/// it (Pro: e-signature + annotate). On-device PencilKit; returns the combined image.
struct MarkupView: View {
    let pageImage: UIImage
    var onDone: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var canvas = PKCanvasView()

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let frame = CropEditorView.fittedRect(imageSize: pageImage.size, container: geo.size)
                ZStack {
                    Color(white: 0.12)
                    Image(uiImage: pageImage).resizable().scaledToFit()
                    PencilCanvas(canvas: canvas)
                        .frame(width: frame.width, height: frame.height)
                        .position(x: frame.midX, y: frame.midY)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Markup & sign")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button("Done") { flatten() }.fontWeight(.semibold) }
                ToolbarItem(placement: .bottomBar) { Button("Clear") { canvas.drawing = PKDrawing() } }
            }
        }
    }

    private func flatten() {
        let size = pageImage.size
        let drawingBounds = canvas.bounds.isEmpty ? CGRect(origin: .zero, size: size) : canvas.bounds
        let overlay = canvas.drawing.image(from: drawingBounds, scale: 1)
        let output = UIGraphicsImageRenderer(size: size).image { _ in
            pageImage.draw(in: CGRect(origin: .zero, size: size))
            overlay.draw(in: CGRect(origin: .zero, size: size))
        }
        onDone(output)
        dismiss()
    }
}

private struct PencilCanvas: UIViewRepresentable {
    let canvas: PKCanvasView
    func makeUIView(context: Context) -> PKCanvasView {
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.tool = PKInkingTool(.pen, color: .black, width: 4)
        return canvas
    }
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
