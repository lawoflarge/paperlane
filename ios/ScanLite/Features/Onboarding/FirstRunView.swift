import SwiftUI

/// One-time welcome that states the wedge plainly — the highest-ROI positioning
/// move (no account / no watermark / no subscription / 100% on-device). Free.
struct FirstRunView: View {
    @Environment(\.dismiss) private var dismiss

    private let promises: [(icon: String, title: String, subtitle: String)] = [
        ("person.crop.circle.badge.xmark", "No account", "Start scanning instantly — no sign-up, ever."),
        ("seal", "No watermark", "Clean PDFs you can actually use and share."),
        ("infinity", "No subscription", "Pay once for Pro, or stay free forever."),
        ("lock.shield", "100% on-device", "Your documents never leave your phone.")
    ]

    var body: some View {
        ZStack {
            PaperTheme.surface.ignoresSafeArea().paperGrain()
            VStack(spacing: 0) {
                Spacer()
                Image(systemName: "doc.text.viewfinder")
                    .font(.system(size: 52, weight: .light))
                    .foregroundStyle(PaperTheme.accent)
                Text("Welcome to ScanLite")
                    .font(.serif(30, .bold))
                    .foregroundStyle(PaperTheme.inkPrimary)
                    .padding(.top, 14)
                Text("The free, private document scanner.")
                    .font(.system(size: 16))
                    .foregroundStyle(PaperTheme.inkSecondary)
                    .padding(.top, 4)

                VStack(spacing: 18) {
                    ForEach(promises, id: \.title) { promise in
                        HStack(spacing: 14) {
                            Image(systemName: promise.icon)
                                .font(.system(size: 22))
                                .foregroundStyle(PaperTheme.accent)
                                .frame(width: 34)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(promise.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(PaperTheme.inkPrimary)
                                Text(promise.subtitle)
                                    .font(.system(size: 13))
                                    .foregroundStyle(PaperTheme.inkSecondary)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)

                Spacer()

                Button { dismiss() } label: {
                    Text("Start scanning")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(PaperTheme.scanButtonGlyph)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(PaperTheme.accent))
                }
                .buttonStyle(InkPressButtonStyle())
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }
}
