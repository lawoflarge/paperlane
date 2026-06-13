import UIKit

/// AdMob unit ids and the banner-display policy.
enum AdConfig {
    /// Debug → Google's official TEST banner unit. Release → real unit (PLACEHOLDER
    /// until the AdMob app/unit is created in the console under pub-6563643868702361).
    static var bannerUnitID: String {
        #if DEBUG
        return "ca-app-pub-3940256099942544/2934735716"
        #else
        return "ca-app-pub-6563643868702361/0000000000" // PLACEHOLDER — AdMob console gate
        #endif
    }
}

/// Pure, testable banner-gating decision. A banner is shown only for a free user
/// who can request ads; a Pro user never shows one.
enum BannerPolicy {
    static func shouldShow(isPro: Bool, canRequestAds: Bool) -> Bool {
        !isPro && canRequestAds
    }
}

extension UIApplication {
    /// The current key window's root view controller (for banner / consent hosting).
    var activeRootViewController: UIViewController? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
