import Testing
@testable import ScanLite

/// Entitlement-derivation logic tests.
///
/// The purchase → `isPro` flip and Restore are verified LIVE in the running app
/// with the scheme's StoreKit configuration (Phase 2b eyeball). `SKTestSession`
/// does not serve products under Xcode 26.5's Swift Testing runner, so the
/// purchase-simulation path is exercised live rather than in this unit harness.
@MainActor
@Suite(.serialized)
struct IAPManagerTests {

    @Test func freshManagerIsNotProAfterDerivingEntitlements() async {
        let manager = IAPManager()
        await manager.refreshEntitlements()
        // No entitlements present -> Pro is off (the default-locked state).
        #expect(manager.isPro == false)
    }

    @Test func displayPriceHasSafeFallbackWhenProductUnavailable() {
        let manager = IAPManager()
        // Product not loaded -> a non-empty fallback price is shown (never blank).
        #expect(!manager.displayPrice.isEmpty)
    }
}
