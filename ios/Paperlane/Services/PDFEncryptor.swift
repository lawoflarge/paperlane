import PDFKit

/// Password-protects a PDF (Pro "encrypt" feature) via PDFKit write options.
struct PDFEncryptor {
    /// Returns an encrypted copy that requires `password` to open, or nil on failure.
    func encrypt(_ pdfData: Data, password: String) -> Data? {
        guard !password.isEmpty, let document = PDFDocument(data: pdfData) else { return nil }
        let options: [PDFDocumentWriteOption: Any] = [
            .userPasswordOption: password,
            .ownerPasswordOption: password
        ]
        return document.dataRepresentation(options: options)
    }
}
