import UIKit

/// Generates synthetic page images for tests so the PDF/OCR/library pipeline runs
/// on the Simulator without camera hardware.
enum ImageFixtures {
    static func page(
        _ label: String,
        size: CGSize = CGSize(width: 612, height: 792),
        background: UIColor = .white
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            background.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48),
                .foregroundColor: UIColor.black
            ]
            (label as NSString).draw(at: CGPoint(x: 40, y: 40), withAttributes: attrs)
        }
    }
}
