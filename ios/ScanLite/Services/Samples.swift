import UIKit

/// Simulator / screenshot helpers. The real capture path is device-only, so the
/// Simulator feeds a faux scanned page to exercise save → library → preview.
enum Samples {
    static func autoName(date: Date = .now) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return "Scan " + formatter.string(from: date)
    }

    static func pages() -> [UIImage] { [invoicePage()] }

    private static func invoicePage() -> UIImage {
        let size = CGSize(width: 612, height: 792)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor(white: 0.98, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            draw("INVOICE", at: CGPoint(x: 48, y: 56), size: 34, weight: .bold)
            draw("ScanLite Supplies Co.", at: CGPoint(x: 48, y: 108), size: 18, weight: .semibold)
            draw("123 Paper Street · Ink City", at: CGPoint(x: 48, y: 136), size: 14, weight: .regular, color: .darkGray)

            UIColor(white: 0.85, alpha: 1).setStroke()
            for index in 0..<8 {
                let y = 220 + CGFloat(index) * 44
                let line = UIBezierPath()
                line.move(to: CGPoint(x: 48, y: y))
                line.addLine(to: CGPoint(x: 564, y: y))
                line.lineWidth = 1
                line.stroke()
                draw("Item \(index + 1)", at: CGPoint(x: 56, y: y - 30), size: 15, weight: .regular)
                draw("$\(12 * (index + 1)).00", at: CGPoint(x: 480, y: y - 30), size: 15, weight: .regular)
            }
            draw("Total: $432.00", at: CGPoint(x: 372, y: 600), size: 20, weight: .bold)
        }
    }

    private static func draw(
        _ string: String,
        at point: CGPoint,
        size: CGFloat,
        weight: UIFont.Weight,
        color: UIColor = .black
    ) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size, weight: weight),
            .foregroundColor: color
        ]
        (string as NSString).draw(at: point, withAttributes: attrs)
    }
}
