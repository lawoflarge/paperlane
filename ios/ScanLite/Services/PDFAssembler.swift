import UIKit
import PDFKit

/// Assembles scanned page images into a real, openable, multi-page PDF.
/// **No watermark, ever** — a watermark draws 1-star reviews and kills the ASO play.
/// Page order and per-page orientation are preserved 1:1 with the input images.
struct PDFAssembler {

    /// Build a multi-page PDF (one page per image) sized to each image in points.
    /// - Precondition: `images` is non-empty.
    func assemble(images: [UIImage]) -> Data {
        precondition(!images.isEmpty, "Cannot assemble a PDF from zero pages")
        let format = UIGraphicsPDFRendererFormat()
        let firstBounds = CGRect(origin: .zero, size: images[0].size)
        let renderer = UIGraphicsPDFRenderer(bounds: firstBounds, format: format)
        return renderer.pdfData { ctx in
            for image in images {
                let pageRect = CGRect(origin: .zero, size: image.size)
                ctx.beginPage(withBounds: pageRect, pageInfo: [:])
                image.draw(in: pageRect)
            }
        }
    }
}
