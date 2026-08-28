import SwiftUI
import GoogleMobileAds
import UIKit

struct AdBannerView: View {
    static let testBannerUnit = "ca-app-pub-3940256099942544/2934735716"        // Google test
    static let releaseBannerUnit = "ca-app-pub-6563643868702361/9971076515"
    @State private var width: CGFloat = 0
    var body: some View {
        ZStack {
            if width > 0 {
                let adSize = currentOrientationAnchoredAdaptiveBanner(width: width)
                BannerViewContainer(adSize: adSize).frame(height: adSize.size.height)
            }
        }
        .frame(maxWidth: .infinity)
        .background { GeometryReader { geo in Color.clear
            .onAppear { width = geo.size.width }
            .onChange(of: geo.size.width) { _, w in width = w } } }
    }
}
private struct BannerViewContainer: UIViewRepresentable {
    let adSize: AdSize
    func makeUIView(context: Context) -> BannerView {
        #if DEBUG
        let unit = AdBannerView.testBannerUnit
        #else
        let unit = AdBannerView.releaseBannerUnit
        #endif
        let banner = BannerView(adSize: adSize); banner.adUnitID = unit
        banner.rootViewController = Self.keyWindowRoot(); banner.load(Request()); return banner
    }
    func updateUIView(_ banner: BannerView, context: Context) {
        guard banner.adSize.size != adSize.size else { return }
        banner.adSize = adSize; banner.load(Request())
    }
    static func keyWindowRoot() -> UIViewController? {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }.first(where: { $0.isKeyWindow })?.rootViewController
    }
}
