import Testing
import Foundation
@testable import ScanLite

struct TextDocumentExporterTests {
    @Test func txtRoundTrips() {
        let text = "Line one\nLine two"
        let data = TextDocumentExporter().txtData(text)
        #expect(String(data: data, encoding: .utf8) == text)
    }

    @Test func docxIsAZipContainingDocumentAndText() {
        let data = TextDocumentExporter().docxData("Hello world\nSecond line")
        #expect(Array(data.prefix(4)) == [0x50, 0x4B, 0x03, 0x04])
        #expect(data.range(of: Data("word/document.xml".utf8)) != nil)
        #expect(data.range(of: Data("Hello world".utf8)) != nil)   // STORED → verbatim
    }

    @Test func docxEscapesXmlSpecials() {
        let data = TextDocumentExporter().docxData("a < b & c")
        #expect(data.range(of: Data("&lt;".utf8)) != nil)
        #expect(data.range(of: Data("&amp;".utf8)) != nil)
    }
}
