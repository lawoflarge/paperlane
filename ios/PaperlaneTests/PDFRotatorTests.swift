import Testing
import PDFKit
@testable import Paperlane

struct PDFRotatorTests {

    private func samplePDF(pages: Int = 2) -> Data {
        PDFAssembler().assemble(images: (0..<pages).map { ImageFixtures.page("\($0)") })
    }

    @Test func rotatesEachPageBy90Clockwise() {
        let data = samplePDF(pages: 2)
        let originalRotation = PDFDocument(data: data)!.page(at: 0)!.rotation

        let rotated = PDFRotator().rotated(data, clockwiseQuarterTurns: 1)
        #expect(rotated != nil)
        let doc = PDFDocument(data: rotated!)!
        #expect(doc.page(at: 0)!.rotation == (originalRotation + 90) % 360)
        #expect(doc.page(at: 1)!.rotation == (originalRotation + 90) % 360)
    }

    @Test func preservesPageCount() {
        let data = samplePDF(pages: 3)
        let rotated = PDFRotator().rotated(data, clockwiseQuarterTurns: 1)
        #expect(PDFDocument(data: rotated!)?.pageCount == 3)
    }

    @Test func fourQuarterTurnsReturnToOriginalOrientation() {
        let data = samplePDF(pages: 1)
        let start = PDFDocument(data: data)!.page(at: 0)!.rotation
        let rotated = PDFRotator().rotated(data, clockwiseQuarterTurns: 4)!
        #expect(PDFDocument(data: rotated)!.page(at: 0)!.rotation % 360 == start % 360)
    }

    @Test func invalidDataReturnsNil() {
        #expect(PDFRotator().rotated(Data([0x00, 0x01, 0x02])) == nil)
    }
}
