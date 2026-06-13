import SwiftUI
import GoogleMobileAds

/// Wraps a v13 `BannerView`. Constructed only when the banner should show (free +
/// consented); a Pro user never instantiates this into the view hierarchy.
struct BannerContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerUnitID
        banner.rootViewController = UIApplication.shared.activeRootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
