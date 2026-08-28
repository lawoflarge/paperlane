import Testing
import PDFKit
import UIKit
@testable import Paperlane

struct PDFPageEditorTests {

    /// Build a PDF whose pages have distinct widths so we can identify them by size.
    private func pdf(sizes: [CGFloat]) -> Data {
        let images = sizes.map { ImageFixtures.page("\(Int($0))", size: CGSize(width: $0, height: $0)) }
        return PDFAssembler().assemble(images: images)
    }

    private func widths(_ data: Data) -> [CGFloat] {
        guard let doc = PDFDocument(data: data) else { return [] }
        return (0..<doc.pageCount).compactMap { doc.page(at: $0)?.bounds(for: .mediaBox).width }
    }

    @Test func reorderMovesPage() {
        let out = PDFPageEditor().reorder(pdf(sizes: [200, 300, 400]), from: 0, to: 2)
        #expect(widths(out ?? Data()) == [300, 400, 200])
    }

    @Test func deleteRemovesPageAndDecrementsCount() {
        let out = PDFPageEditor().deletePage(pdf(sizes: [200, 300, 400]), at: 1)
        #expect(widths(out ?? Data()) == [200, 400])
    }

    @Test func deleteLastRemainingPageIsRefused() {
        #expect(PDFPageEditor().deletePage(pdf(sizes: [200]), at: 0) == nil)
    }

    @Test func appendConcatenatesPages() {
        let out = PDFPageEditor().append(pdf(sizes: [300, 400]), to: pdf(sizes: [200]))
        #expect(widths(out ?? Data()) == [200, 300, 400])
    }

    @Test func reorderOutOfRangeReturnsInputUnchanged() {
        let data = pdf(sizes: [200, 300])
        let out = PDFPageEditor().reorder(data, from: 0, to: 5)
        #expect(widths(out ?? Data()) == [200, 300])
    }
}
