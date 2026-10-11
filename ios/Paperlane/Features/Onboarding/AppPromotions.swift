import CrossPromotionCore
import CrossPromotionUI
import SwiftUI

@MainActor
enum AppPromotions {
    static func makeStore() -> PromotionStore? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "CrossPromotionBaseURL") as? String,
              let url = URL(string: value), url.scheme == "https", url.host != nil,
              url.user == nil, url.password == nil else { return nil }
        return PromotionStore(
            source: PromotionIdentity(appStoreID: "6780053638", bundleID: "de.levinschwab.scanlite"),
            baseURL: url, eventsEnabled: true
        )
    }
}

@MainActor
struct AppPromotionSection: View {
    let store: PromotionStore
    let viewport: CGRect
    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            if !store.promotions.isEmpty {
                Section(String(localized: "More apps")) { rows }
            }
        }
        .tint(PaperTheme.accent)
    }

    private var rows: some View {
        ForEach(store.promotions) { promotion in
            CrossPromotionRow(
                promotion: promotion,
                appStoreActionTitle: String(localized: "View in App Store"),
                style: .init(titleFont: .headline, benefitFont: .subheadline, titleColor: PaperTheme.inkPrimary, benefitColor: PaperTheme.inkSecondary)
            ) {
                CrossPromotionIcon(promotion.iconURL)
            } onSelect: { selected in
                openURL(selected.appStoreURL) { accepted in
                    if accepted { store.recordClick(selected) }
                }
            }
            .promotionImpression(promotion, store: store, viewport: viewport)
        }
    }
}
