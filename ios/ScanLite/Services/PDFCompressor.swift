import PDFKit
import UIKit

/// Re-encodes each PDF page as a downscaled JPEG to shrink share/email size (Pro).
/// Pure, on-device. Lower quality → smaller bytes.
struct PDFCompressor {
    enum Quality: String, CaseIterable, Identifiable {
        case low, medium, high
        var id: String { rawValue }
        var label: String {
            switch self {
            case .low: return "Smallest"
            case .medium: return "Balanced"
            case .high: return "Best quality"
            }
        }
        var jpeg: CGFloat { self == .low ? 0.3 : self == .medium ? 0.5 : 0.75 }
        var scale: CGFloat { self == .low ? 0.6 : self == .medium ? 0.8 : 1.0 }
    }

    func compress(_ data: Data, quality: Quality) -> Data? {
        guard let pdf = PDFDocument(data: data), pdf.pageCount > 0 else { return nil }
        var images: [UIImage] = []
        for index in 0..<pdf.pageCount {
            guard let page = pdf.page(at: index) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            let target = CGSize(width: max(1, bounds.width * quality.scale),
                                height: max(1, bounds.height * quality.scale))
            let raster = page.thumbnail(of: target, for: .mediaBox)
            if let jpeg = raster.jpegData(compressionQuality: quality.jpeg),
               let reencoded = UIImage(data: jpeg) {
                images.append(reencoded)
            }
        }
        guard !images.isEmpty else { return nil }
        return PDFAssembler().assemble(images: images)
    }
}
