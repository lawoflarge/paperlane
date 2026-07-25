import Foundation
import GoogleMobileAds
import UserMessagingPlatform
import AppTrackingTransparency
import UIKit

@MainActor @Observable
final class ConsentManager {
    private(set) var canRequestAds = false
    private var started = false

    func bootstrap() async {
        let params = RequestParameters()
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            ConsentInformation.shared.requestConsentInfoUpdate(with: params) { _ in c.resume() }
        }
        if let root = Self.topViewController() {
            await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
                ConsentForm.loadAndPresentIfRequired(from: root) { _ in c.resume() }
            }
        }
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            ATTrackingManager.requestTrackingAuthorization { _ in c.resume() }
        }
        if ConsentInformation.shared.canRequestAds { startAdsIfNeeded() }
    }
    func startAdsIfNeeded() {
        guard !started else { return }
        started = true
        MobileAds.shared.start(completionHandler: { _ in })
        canRequestAds = true
    }
    var privacyOptionsRequired: Bool { ConsentInformation.shared.privacyOptionsRequirementStatus == .required }
    func presentPrivacyOptions() {
        guard let root = Self.topViewController() else { return }
        ConsentForm.presentPrivacyOptionsForm(from: root) { _ in }
    }
    static func topViewController() -> UIViewController? {
        let root = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }.first(where: { $0.isKeyWindow })?.rootViewController
        var top = root; while let p = top?.presentedViewController { top = p }; return top
    }
}
