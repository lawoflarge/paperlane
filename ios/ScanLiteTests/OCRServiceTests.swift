import Testing
import PDFKit
import UIKit
@testable import ScanLite

struct OCRServiceTests {

    @Test func searchablePDFContainsSelectableText() {
        let image = ImageFixtures.page("INVOICE TOTAL DUE", size: CGSize(width: 800, height: 400))
        let data = OCRService().makeSearchablePDF(images: [image])
        let pdf = PDFDocument(data: data)
        #expect(pdf != nil)
        #expect(pdf?.pageCount == 1)
        let text = pdf?.string ?? ""
        // A searchable text layer must be present (Vision recognizes the drawn text).
        #expect(!text.isEmpty)
    }

    @Test func recognizeTextReturnsContent() {
        let image = ImageFixtures.page("HELLO", size: CGSize(width: 600, height: 300))
        let recognized = OCRService().recognizeText(in: image)
        #expect(!recognized.isEmpty)
    }
}
