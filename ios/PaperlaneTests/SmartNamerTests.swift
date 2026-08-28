import Testing
import Foundation
@testable import Paperlane

struct SmartNamerTests {
    /// Empty OCR text never invokes the model — it returns the deterministic date
    /// fallback, so this is stable regardless of Apple Intelligence availability.
    @Test func emptyTextFallsBackToDateName() async {
        let name = await SmartNamer.suggest(ocrText: "   ", date: Date(timeIntervalSince1970: 0))
        #expect(name.hasPrefix("Scan "))
    }
}
