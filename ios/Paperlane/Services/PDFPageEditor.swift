import PDFKit

/// Pure page-level edits on a PDF's bytes (free): reorder, delete, append.
/// Always returns new `Data`; never mutates the input bytes.
struct PDFPageEditor {

    /// Move the page at `from` to index `to`. Out-of-range → unchanged input;
    /// invalid document → nil.
    func reorder(_ data: Data, from: Int, to: Int) -> Data? {
        guard let pdf = PDFDocument(data: data) else { return nil }
        let count = pdf.pageCount
        guard from >= 0, from < count, to >= 0, to < count else { return data }
        guard from != to, let page = pdf.page(at: from) else { return data }
        pdf.removePage(at: from)
        pdf.insert(page, at: min(to, pdf.pageCount))
        return pdf.dataRepresentation()
    }

    /// Delete the page at `index`. Refuses to delete the last remaining page
    /// (a document must keep at least one page) → nil.
    func deletePage(_ data: Data, at index: Int) -> Data? {
        guard let pdf = PDFDocument(data: data), index >= 0, index < pdf.pageCount else { return nil }
        guard pdf.pageCount > 1 else { return nil }
        pdf.removePage(at: index)
        return pdf.dataRepresentation()
    }

    /// Append every page of `other` to the end of `data`.
    func append(_ other: Data, to data: Data) -> Data? {
        guard let base = PDFDocument(data: data), let add = PDFDocument(data: other) else { return nil }
        for i in 0..<add.pageCount {
            if let page = add.page(at: i) { base.insert(page, at: base.pageCount) }
        }
        return base.dataRepresentation()
    }
}
