import Testing
@testable import ScanLite

struct BannerPolicyTests {

    @Test func showsOnlyForFreeConsentedUser() {
        #expect(BannerPolicy.shouldShow(isPro: false, canRequestAds: true) == true)
    }

    @Test func neverShowsForProUser() {
        #expect(BannerPolicy.shouldShow(isPro: true, canRequestAds: true) == false)
    }

    @Test func neverShowsWithoutConsent() {
        #expect(BannerPolicy.shouldShow(isPro: false, canRequestAds: false) == false)
    }
}
