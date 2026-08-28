import Testing
import UIKit
@testable import Paperlane

struct ImageExporterTests {

    @Test func exportsJPEGWithMagicBytes() {
        let data = ImageExporter().export(ImageFixtures.page("x"), as: .jpeg)
        #expect(data != nil)
        #expect((data?.count ?? 0) > 0)
        // JPEG starts with FF D8.
        #expect(data?.first == 0xFF)
    }

    @Test func exportsPNGWithMagicBytes() {
        let data = ImageExporter().export(ImageFixtures.page("x"), as: .png)
        #expect(data != nil)
        // PNG signature first byte is 0x89.
        #expect(data?.first == 0x89)
    }
}
