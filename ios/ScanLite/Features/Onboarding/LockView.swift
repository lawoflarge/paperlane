import SwiftUI

/// Shown when the library is locked (app-lock enabled + app returned from
/// background). Auto-prompts Face ID on appear; Unlock retries. Free, on-device.
struct LockView: View {
    @Environment(AppLock.self) private var appLock

    var body: some View {
        ZStack {
            PaperTheme.surface.ignoresSafeArea().paperGrain()
            VStack(spacing: 18) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(PaperTheme.accent)
                Text("ScanLite is locked")
                    .font(.serif(24, .bold))
                    .foregroundStyle(PaperTheme.inkPrimary)
                Text("Your documents stay private to this device.")
                    .font(.system(size: 15))
                    .foregroundStyle(PaperTheme.inkSecondary)
                    .multilineTextAlignment(.center)
                Button { Task { await appLock.authenticate() } } label: {
                    Label("Unlock", systemImage: "faceid")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(PaperTheme.scanButtonGlyph)
                        .frame(width: 200, height: 52)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(PaperTheme.accent))
                }
                .buttonStyle(InkPressButtonStyle())
                .padding(.top, 8)
            }
            .padding()
        }
        .task { await appLock.authenticate() }
    }
}
