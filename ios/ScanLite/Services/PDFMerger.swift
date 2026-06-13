import PDFKit

/// Combines several PDFs into one (Pro "merge / batch-combine" feature).
struct PDFMerger {
    /// Merge PDFs in order; returns nil if nothing valid to merge.
    func merge(_ pdfDatas: [Data]) -> Data? {
        let merged = PDFDocument()
        var insertIndex = 0
        for data in pdfDatas {
            guard let doc = PDFDocument(data: data) else { continue }
            for pageIndex in 0..<doc.pageCount {
                if let page = doc.page(at: pageIndex) {
                    merged.insert(page, at: insertIndex)
                    insertIndex += 1
                }
            }
        }
        return insertIndex > 0 ? merged.dataRepresentation() : nil
    }
}
