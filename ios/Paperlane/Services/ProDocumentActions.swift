import PDFKit
import UIKit

/// Performs the Pro operations on a stored document's PDF (OCR, image export,
/// encryption). Reads/writes through `DocumentFileStore`.
struct ProDocumentActions {
    let files: DocumentFileStore

    /// First page exported as JPG/PNG.
    func exportImage(_ document: ScannedDocument, format: ImageExporter.Format) -> Data? {
        guard let image = pageImages(of: document)?.first else { return nil }
        return ImageExporter().export(image, as: format)
    }

    /// Password-protected copy of the PDF.
    func encrypted(_ document: ScannedDocument, password: String) -> Data? {
        guard let data = try? files.read(fileName: document.fileName) else { return nil }
        return PDFEncryptor().encrypt(data, password: password)
    }

    private func pageImages(of document: ScannedDocument) -> [UIImage]? {
        guard let data = try? files.read(fileName: document.fileName),
              let pdf = PDFDocument(data: data) else { return nil }
        var images: [UIImage] = []
        for index in 0..<pdf.pageCount {
            guard let page = pdf.page(at: index) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            images.append(page.thumbnail(of: bounds.size, for: .mediaBox))
        }
        return images
    }
}
