import Testing
import PDFKit
@testable import Paperlane

struct PDFCompressorTests {
    private func bigPDF() -> Data {
        PDFAssembler().assemble(images: [ImageFixtures.page("DOCUMENT TEXT", size: CGSize(width: 1600, height: 2000))])
    }

    @Test func compressionProducesValidPdfWithSamePageCount() {
        let out = PDFCompressor().compress(bigPDF(), quality: .low)
        #expect(out != nil)
        #expect(PDFDocument(data: out!)?.pageCount == 1)
    }

    @Test func lowerQualityIsNotLargerThanHigher() {
        let data = bigPDF()
        let low = PDFCompressor().compress(data, quality: .low)!
        let high = PDFCompressor().compress(data, quality: .high)!
        #expect(low.count <= high.count)
    }

    @Test func invalidDataReturnsNil() {
        #expect(PDFCompressor().compress(Data([0, 1, 2]), quality: .medium) == nil)
    }
}
