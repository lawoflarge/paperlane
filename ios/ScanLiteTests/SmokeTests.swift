import Testing
@testable import ScanLite

/// Phase 0 smoke test: proves the test target links the app module and the
/// Swift Testing runner works. Real coverage lands in Phase 1+.
struct SmokeTests {
    @Test func appModuleLinks() {
        #expect(Bool(true))
    }
}
