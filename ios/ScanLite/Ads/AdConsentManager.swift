import Foundation
import Observation
import AppTrackingTransparency
import GoogleMobileAds
import UserMessagingPlatform

/// UMP consent + ATT, then starts the Mobile Ads SDK. Exposes `canRequestAds`
/// which (with `!isPro`) gates the banner. Order: UMP first, ATT second.
@MainActor
@Observable
final class AdConsentManager {
    private(set) var canRequestAds = false
    private var started = false

    func bootstrap() async {
        let parameters = RequestParameters()
        await requestConsentInfoUpdate(parameters)
        await loadAndPresentConsentFormIfRequired()
        await requestTrackingAuthorization()

        if ConsentInformation.shared.canRequestAds {
            startAds()
        }
    }

    private func requestConsentInfoUpdate(_ parameters: RequestParameters) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { _ in
                continuation.resume()
            }
        }
    }

    private func loadAndPresentConsentFormIfRequired() async {
        guard let root = UIApplication.shared.activeRootViewController else { return }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            ConsentForm.loadAndPresentIfRequired(from: root) { _ in
                continuation.resume()
            }
        }
    }

    private func requestTrackingAuthorization() async {
        _ = await ATTrackingManager.requestTrackingAuthorization()
    }

    private func startAds() {
        guard !started else { return }
        started = true
        MobileAds.shared.start(completionHandler: nil)
        canRequestAds = true
    }
}
