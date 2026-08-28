import Testing
import PDFKit
@testable import Paperlane

struct PDFMergerTests {

    @Test func mergeSumsPageCounts() {
        let a = PDFAssembler().assemble(images: [ImageFixtures.page("A1"), ImageFixtures.page("A2")])
        let b = PDFAssembler().assemble(images: [ImageFixtures.page("B1")])
        let merged = PDFMerger().merge([a, b])
        #expect(merged != nil)
        #expect(PDFDocument(data: merged!)?.pageCount == 3)
    }

    @Test func mergeOfNothingIsNil() {
        #expect(PDFMerger().merge([]) == nil)
    }
}
