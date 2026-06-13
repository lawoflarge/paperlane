import SwiftUI
import SwiftData

@main
struct ScanLiteApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: ScannedDocument.self)
    }
}
