import PDFKit
import UIKit

/// Burns an image (a signature or a flattened annotation layer) onto a PDF page at
/// a normalized rect (Pro). On-device. The stamped page is rasterized so the mark
/// is baked into the file; other pages stay untouched. Page count is preserved.
struct PDFStamper {

    /// `rect` is normalized (0...1) in the page, origin TOP-LEFT.
    func stamp(_ image: UIImage, on data: Data, pageIndex: Int, normalizedRect rect: CGRect) -> Data? {
        guard let pdf = PDFDocument(data: data), pageIndex >= 0, pageIndex < pdf.pageCount,
              let page = pdf.page(at: pageIndex) else { return nil }
        let bounds = page.bounds(for: .mediaBox)
        let pageImage = page.thumbnail(of: bounds.size, for: .mediaBox)   // upright raster
        let flattened = UIGraphicsImageRenderer(size: bounds.size).image { _ in
            pageImage.draw(in: CGRect(origin: .zero, size: bounds.size))
            let target = CGRect(
                x: rect.minX * bounds.width,
                y: rect.minY * bounds.height,
                width: rect.width * bounds.width,
                height: rect.height * bounds.height
            )
            image.draw(in: target)
        }
        guard let newPage = PDFPage(image: flattened) else { return nil }
        pdf.removePage(at: pageIndex)
        pdf.insert(newPage, at: pageIndex)
        return pdf.dataRepresentation()
    }
}
