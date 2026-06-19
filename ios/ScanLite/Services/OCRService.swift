import Vision
import PDFKit
import UIKit

/// Builds a searchable PDF: each page is the scanned image with a selectable OCR
/// text layer drawn on top in clear ink (the "invisible-made-searchable" magic).
/// On-device Vision only — scanned content never leaves the phone.
struct OCRService {

    /// A searchable PDF plus the plain recognized text, produced in a single OCR
    /// pass (the text feeds free in-document search + Pro text export).
    struct SearchablePDF {
        let data: Data
        let text: String
    }

    /// OCR every page once: draw the invisible selectable layer AND collect the
    /// recognized text. One Vision pass per page (no double work).
    func makeSearchable(images: [UIImage]) -> SearchablePDF {
        precondition(!images.isEmpty, "Cannot OCR zero pages")
        let firstBounds = CGRect(origin: .zero, size: images[0].size)
        let renderer = UIGraphicsPDFRenderer(bounds: firstBounds)
        var collected: [String] = []
        let data = renderer.pdfData { ctx in
            for image in images {
                let pageRect = CGRect(origin: .zero, size: image.size)
                ctx.beginPage(withBounds: pageRect, pageInfo: [:])
                image.draw(in: pageRect)
                if let cg = image.cgImage {
                    let observations = recognize(cg)
                    drawTextLayer(observations, pageSize: image.size)
                    let pageText = observations
                        .compactMap { $0.topCandidates(1).first?.string }
                        .joined(separator: "\n")
                    if !pageText.isEmpty { collected.append(pageText) }
                }
            }
        }
        return SearchablePDF(data: data, text: collected.joined(separator: "\n"))
    }

    /// Assemble images into a PDF whose text is selectable/searchable.
    func makeSearchablePDF(images: [UIImage]) -> Data {
        makeSearchable(images: images).data
    }

    /// Plain recognized text for a single image (used for copy / search index).
    func recognizeText(in image: UIImage) -> String {
        guard let cg = image.cgImage else { return "" }
        return recognize(cg)
            .compactMap { $0.topCandidates(1).first?.string }
            .joined(separator: "\n")
    }

    private func recognize(_ cgImage: CGImage) -> [VNRecognizedTextObservation] {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? handler.perform([request])
        return request.results ?? []
    }

    /// Draw each recognized word as clear (alpha-0) text positioned over its box,
    /// so glyphs live in the PDF content stream (selectable) but are not visible.
    /// Vision boxes are normalized + bottom-left; the PDF renderer context is
    /// UIKit top-left, so y is flipped via (1 - maxY).
    private func drawTextLayer(_ observations: [VNRecognizedTextObservation], pageSize: CGSize) {
        for observation in observations {
            guard let text = observation.topCandidates(1).first?.string else { continue }
            let box = observation.boundingBox
            let rect = CGRect(
                x: box.minX * pageSize.width,
                y: (1 - box.maxY) * pageSize.height,
                width: box.width * pageSize.width,
                height: box.height * pageSize.height
            )
            guard rect.height > 1 else { continue }
            let fontSize = max(4, fittedFontSize(text, in: rect))
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor.clear
            ]
            (text as NSString).draw(in: rect, withAttributes: attributes)
        }
    }

    /// Binary-search a font size whose rendered width best matches the box width.
    private func fittedFontSize(_ text: String, in rect: CGRect) -> CGFloat {
        var low: CGFloat = 4
        var high = max(6, rect.height * 1.6)
        for _ in 0..<8 {
            let mid = (low + high) / 2
            let width = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: mid)]).width
            if width > rect.width { high = mid } else { low = mid }
        }
        return low
    }
}
