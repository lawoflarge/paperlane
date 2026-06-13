import SwiftUI

/// Physical "press ink into paper" button style: scale + downward translate on
/// press. Reused by the Scan button and the paywall CTA.
struct InkPressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .offset(y: configuration.isPressed ? 2 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// The single giant home-screen Scan affordance — an ink slab with a reversed
/// aperture glyph, accent ring, cast shadow, and a haptic on tap.
struct InkScanButton: View {
    var action: () -> Void
    @State private var taps = 0

    var body: some View {
        Button {
            taps += 1
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 26, weight: .semibold))
                Text("Scan")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(PaperTheme.scanButtonGlyph)
            .frame(maxWidth: .infinity)
            .frame(height: 84)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(PaperTheme.scanButtonFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(PaperTheme.accent.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: PaperTheme.inkPrimary.opacity(0.22), radius: 16, y: 9)
        }
        .buttonStyle(InkPressButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: taps)
    }
}
