import PDFKit
import UIKit

/// Pure helpers for importing an existing PDF or photo into the pipeline (free),
/// so imported files can flow through the same crop/filter/OCR path as captures.
struct DocumentImporter {
    func pageCount(ofPDF data: Data) -> Int? { PDFDocument(data: data)?.pageCount }

    /// Rasterize each PDF page to an image, capped on the long edge.
    func images(fromPDF data: Data, maxDimension: CGFloat = 2000) -> [UIImage] {
        guard let pdf = PDFDocument(data: data) else { return [] }
        return (0..<pdf.pageCount).compactMap { pdf.page(at: $0) }.map { page in
            let bounds = page.bounds(for: .mediaBox)
            let scale = min(1, maxDimension / max(bounds.width, bounds.height))
            let size = CGSize(width: max(1, bounds.width * scale), height: max(1, bounds.height * scale))
            return page.thumbnail(of: size, for: .mediaBox)
        }
    }
}
