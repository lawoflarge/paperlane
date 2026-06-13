import SwiftUI
import SwiftData

@main
struct ScanLiteApp: App {
    @State private var iap = IAPManager()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(iap)
                .task { await iap.start() }
        }
        .modelContainer(for: ScannedDocument.self)
    }
}
