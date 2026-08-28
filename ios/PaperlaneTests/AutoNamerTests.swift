import Testing
import Foundation
@testable import Paperlane

struct AutoNamerTests {
    private let fixedDate = Date(timeIntervalSince1970: 0)

    @Test func usesFirstUsableOcrLine() {
        let name = AutoNamer.suggest(ocrText: "INVOICE 2026\nAcme Corp", date: fixedDate)
        #expect(name.hasPrefix("INVOICE 2026"))
    }

    @Test func fallsBackToDateWhenNoText() {
        let name = AutoNamer.suggest(ocrText: "   \n  ", date: fixedDate)
        #expect(name.hasPrefix("Scan "))
    }

    @Test func longLineIsTruncatedWithEllipsis() {
        let name = AutoNamer.suggest(ocrText: String(repeating: "A", count: 80), date: fixedDate)
        #expect(name.contains("…"))
        #expect(name.hasPrefix(String(repeating: "A", count: 40)))
    }

    @Test func skipsTooShortLines() {
        let name = AutoNamer.suggest(ocrText: "ab\nReal Title Here", date: fixedDate)
        #expect(name.hasPrefix("Real Title Here"))
    }
}
