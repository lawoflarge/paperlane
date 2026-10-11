import SwiftUI
import CrossPromotionUI

/// Settings: privacy app-lock toggle, Pro status / restore, and the wedge footer.
struct SettingsView: View {
    @Environment(AppLock.self) private var appLock
    @Environment(IAPManager.self) private var iap
    @Environment(ConsentManager.self) private var consent
    @Environment(\.dismiss) private var dismiss
    @State private var lockOn = false
    @State private var promotions = AppPromotions.makeStore()

    var body: some View {
        NavigationStack {
            PromotionViewport { viewport in
            List {
                Section("Privacy") {
                    Toggle(isOn: $lockOn) {
                        Label("Lock with Face ID", systemImage: "faceid")
                    }
                    .onChange(of: lockOn) { _, on in appLock.setEnabled(on) }
                }

                Section("Paperlane Pro") {
                    if iap.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(PaperTheme.successLedger)
                    } else {
                        Button { Task { await iap.restore() } } label: {
                            Label("Restore purchases", systemImage: "arrow.clockwise")
                        }
                    }
                }

                Section {
                    if consent.privacyOptionsRequired {
                        Button { consent.presentPrivacyOptions() } label: {
                            Label("Ad privacy options", systemImage: "hand.raised.circle")
                        }
                    }
                    Link(destination: URL(string: "https://getpaperlane.vercel.app/privacy")!) {
                        Label("Privacy policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "https://getpaperlane.vercel.app/terms")!) {
                        Label("Terms of use", systemImage: "doc.text")
                    }
                } footer: {
                    Text("No account. No watermark. No subscription. Documents are processed on your device.")
                }
                if let promotions {
                    AppPromotionSection(store: promotions, viewport: viewport)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .tint(PaperTheme.accent)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .onAppear { lockOn = appLock.isEnabled }
            }
            .promotionLifecycle(promotions)
        }
    }
}
