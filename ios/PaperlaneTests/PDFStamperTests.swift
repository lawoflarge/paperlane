import Testing
import PDFKit
import UIKit
@testable import Paperlane

struct PDFStamperTests {
    private func onePage() -> Data {
        PDFAssembler().assemble(images: [ImageFixtures.page("DOC", size: CGSize(width: 600, height: 800))])
    }

    @Test func stampPreservesPageCountAndReturnsValidPdf() {
        let sig = ImageFixtures.page("sign", size: CGSize(width: 200, height: 80))
        let out = PDFStamper().stamp(
            sig, on: onePage(), pageIndex: 0,
            normalizedRect: CGRect(x: 0.5, y: 0.8, width: 0.4, height: 0.1)
        )
        #expect(out != nil)
        #expect(PDFDocument(data: out!)?.pageCount == 1)
    }

    @Test func outOfRangePageReturnsNil() {
        let sig = ImageFixtures.page("s", size: CGSize(width: 50, height: 50))
        #expect(PDFStamper().stamp(sig, on: onePage(), pageIndex: 9, normalizedRect: .zero) == nil)
    }
}
