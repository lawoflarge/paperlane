import Testing
import PDFKit
@testable import Paperlane

struct DocumentImporterTests {
    private func twoPagePDF() -> Data {
        PDFAssembler().assemble(images: [ImageFixtures.page("1"), ImageFixtures.page("2")])
    }

    @Test func readsPageCountOfValidPDF() {
        #expect(DocumentImporter().pageCount(ofPDF: twoPagePDF()) == 2)
    }

    @Test func invalidPDFHasNilPageCount() {
        #expect(DocumentImporter().pageCount(ofPDF: Data([0, 1, 2])) == nil)
    }

    @Test func rasterizesEachPageToAnImage() {
        #expect(DocumentImporter().images(fromPDF: twoPagePDF()).count == 2)
    }
}
