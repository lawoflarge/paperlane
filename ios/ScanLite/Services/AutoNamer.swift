import Foundation

/// Suggests a document name from the OCR text + date (free). Pure + deterministic.
/// A lightweight, on-device taste of the Pro AI naming; falls back to a date stamp
/// when no usable text was recognized.
enum AutoNamer {
    static func suggest(ocrText: String, date: Date = .now) -> String {
        let firstLine = ocrText
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .first { $0.count >= 3 }
        let stamp = dateStamp(date)
        guard let line = firstLine, !line.isEmpty else { return "Scan \(stamp)" }
        let clipped = line.count > 40
            ? String(line.prefix(40)).trimmingCharacters(in: .whitespaces) + "…"
            : line
        return "\(clipped) — \(stamp)"
    }

    private static func dateStamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}
