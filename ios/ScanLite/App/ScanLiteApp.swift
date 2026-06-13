import SwiftUI
import SwiftData

@main
struct ScanLiteApp: App {
    @State private var iap = IAPManager()
    @State private var ads = AdConsentManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(iap)
                .environment(ads)
                .task {
                    await iap.start()
                    await ads.bootstrap()
                }
        }
        .modelContainer(for: ScannedDocument.self)
    }
}
