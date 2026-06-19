import SwiftUI

/// Settings: privacy app-lock toggle, Pro status / restore, and the wedge footer.
struct SettingsView: View {
    @Environment(AppLock.self) private var appLock
    @Environment(IAPManager.self) private var iap
    @Environment(\.dismiss) private var dismiss
    @State private var lockOn = false

    var body: some View {
        NavigationStack {
            List {
                Section("Privacy") {
                    Toggle(isOn: $lockOn) {
                        Label("Lock with Face ID", systemImage: "faceid")
                    }
                    .onChange(of: lockOn) { _, on in appLock.setEnabled(on) }
                }

                Section("ScanLite Pro") {
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
                    Link(destination: URL(string: "https://getscanlite.vercel.app/privacy")!) {
                        Label("Privacy policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "https://getscanlite.vercel.app/terms")!) {
                        Label("Terms of use", systemImage: "doc.text")
                    }
                } footer: {
                    Text("No account. No watermark. No subscription. 100% on-device.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .tint(PaperTheme.accent)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
            .onAppear { lockOn = appLock.isEnabled }
        }
    }
}
