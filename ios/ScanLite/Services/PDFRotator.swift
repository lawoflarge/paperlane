import PDFKit

/// Rotates every page of a PDF in 90° steps (free "rotate pages" feature).
/// Operates on in-memory `Data` so it is trivially unit-testable.
struct PDFRotator {
    /// Returns a copy of `data` with each page rotated clockwise by
    /// `clockwiseQuarterTurns × 90°`. Returns nil if the data is not a valid PDF.
    func rotated(_ data: Data, clockwiseQuarterTurns: Int = 1) -> Data? {
        guard let document = PDFDocument(data: data) else { return nil }
        let delta = clockwiseQuarterTurns * 90
        for index in 0..<document.pageCount {
            guard let page = document.page(at: index) else { continue }
            // Normalise so repeated rotations never accumulate past 360°.
            page.rotation = (page.rotation + delta) % 360
        }
        return document.dataRepresentation()
    }
}
