import Testing
import PDFKit
import UIKit
@testable import Paperlane

struct PDFAssemblerTests {

    @Test func assemblesCorrectPageCount() {
        let images = [ImageFixtures.page("1"), ImageFixtures.page("2"), ImageFixtures.page("3")]
        let data = PDFAssembler().assemble(images: images)
        let pdf = PDFDocument(data: data)
        #expect(pdf != nil)
        #expect(pdf?.pageCount == 3)
        #expect(data.count > 0)
    }

    @Test func preservesPageOrientation() {
        let portrait = ImageFixtures.page("p", size: CGSize(width: 400, height: 800))
        let landscape = ImageFixtures.page("l", size: CGSize(width: 800, height: 400))
        let data = PDFAssembler().assemble(images: [portrait, landscape])
        let pdf = PDFDocument(data: data)
        let p0 = pdf?.page(at: 0)?.bounds(for: .mediaBox) ?? .zero
        let p1 = pdf?.page(at: 1)?.bounds(for: .mediaBox) ?? .zero
        #expect(p0.width < p0.height)   // page 1 stays portrait
        #expect(p1.width > p1.height)   // page 2 stays landscape
    }

    @Test func producesValidNonEmptyPDF() {
        let data = PDFAssembler().assemble(images: [ImageFixtures.page("x")])
        #expect(PDFDocument(data: data) != nil)
        #expect(data.count > 100)
    }
}
