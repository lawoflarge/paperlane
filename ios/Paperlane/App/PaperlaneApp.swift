import SwiftUI
import SwiftData

@main
struct PaperlaneApp: App {
    @State private var iap = IAPManager()
    @State private var appLock = AppLock()
    @State private var consent = ConsentManager()
    @State private var gate = AdGate()
    @State private var interstitial = InterstitialAdManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            Group {
                if appLock.state == .locked {
                    LockView()
                } else {
                    HomeView()
                }
            }
            .environment(iap)
            .environment(appLock)
            .environment(consent)
            .environment(gate)
            .environment(interstitial)
            .task {
                await iap.start()
                await consent.bootstrap()
                AdGate.bumpSession()
                if consent.canRequestAds && !iap.isPro { interstitial.preload() }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background { appLock.lockIfEnabled() }
            }
        }
        .modelContainer(for: [ScannedDocument.self, Folder.self])
    }
}
