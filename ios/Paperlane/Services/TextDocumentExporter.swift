import Foundation

/// Exports recognized OCR text as copyable text, a `.txt` file, or a minimal but
/// valid `.docx` (OOXML) — all on-device (Pro). We sell text *extraction* (the part
/// Apple leaves clumsy); the searchable layer itself is free.
struct TextDocumentExporter {

    func plainText(_ text: String) -> String { text }

    func txtData(_ text: String) -> Data { Data(text.utf8) }

    /// Build a `.docx`: a ZIP of `[Content_Types].xml`, `_rels/.rels`, and
    /// `word/document.xml` with the text split into paragraphs.
    func docxData(_ text: String) -> Data {
        let paragraphs = text.split(whereSeparator: \.isNewline).map { xmlEscape(String($0)) }
        let body = paragraphs.isEmpty
            ? "<w:p/>"
            : paragraphs.map { "<w:p><w:r><w:t xml:space=\"preserve\">\($0)</w:t></w:r></w:p>" }.joined()
        let document = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>\(body)</w:body></w:document>
        """
        let contentTypes = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>
        """
        let rels = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
        """
        return Zip.archive([
            (name: "[Content_Types].xml", data: Data(contentTypes.utf8)),
            (name: "_rels/.rels", data: Data(rels.utf8)),
            (name: "word/document.xml", data: Data(document.utf8))
        ])
    }

    private func xmlEscape(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }
}
