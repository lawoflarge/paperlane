import SwiftUI
import SwiftData

@main
struct ScanLiteApp: App {
    @State private var iap = IAPManager()
    @State private var appLock = AppLock()
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
            .task { await iap.start() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background { appLock.lockIfEnabled() }
            }
        }
        .modelContainer(for: [ScannedDocument.self, Folder.self])
    }
}
