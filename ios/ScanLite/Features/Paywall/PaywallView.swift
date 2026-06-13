import SwiftUI

/// "Ledger" paywall — a letterpress receipt: serif headline, a hairline-ruled
/// feature ledger, the one-time price set large, and an ink-press "Go Pro" CTA.
/// One-time purchase, no subscription.
struct PaywallView: View {
    @Environment(IAPManager.self) private var iap
    @Environment(\.dismiss) private var dismiss
    @State private var working = false

    private let features: [(icon: String, text: String)] = [
        ("text.viewfinder", "Searchable OCR text layer"),
        ("doc.on.doc", "Combine pages into one PDF"),
        ("photo", "Export as JPG or PNG"),
        ("lock", "Password-protect your PDFs"),
        ("textformat", "Custom file naming")
    ]

    var body: some View {
        ZStack {
            PaperTheme.surface.ignoresSafeArea().paperGrain()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundStyle(PaperTheme.inkTertiary)
                    }
                }
                .padding([.top, .trailing], 16)

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        ledger
                        priceBlock
                        cta
                        Button("Restore Purchases") { Task { await iap.restore(); if iap.isPro { dismiss() } } }
                            .font(.system(size: 15, weight: .medium))
                            .tint(PaperTheme.inkSecondary)
                        legal
                    }
                    .padding(24)
                }
            }
        }
        .onChange(of: iap.isPro) { _, isPro in if isPro { dismiss() } }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("ScanLite Pro")
                .font(.serif(34, .bold))
                .foregroundStyle(PaperTheme.inkPrimary)
            Text("Unlock the full toolkit. Pay once, keep it forever.")
                .font(.system(size: 16))
                .foregroundStyle(PaperTheme.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }

    private var ledger: some View {
        VStack(spacing: 0) {
            ForEach(features, id: \.text) { feature in
                HStack(spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 17))
                        .foregroundStyle(PaperTheme.accent)
                        .frame(width: 26)
                    Text(feature.text)
                        .font(.system(size: 16))
                        .foregroundStyle(PaperTheme.inkPrimary)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(PaperTheme.successLedger)
                }
                .padding(.vertical, 14)
                Rectangle().fill(PaperTheme.separator).frame(height: 0.5)
            }
        }
        .padding(.horizontal, 18)
        .background(PaperTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(PaperTheme.cardEdge, lineWidth: 0.5))
    }

    private var priceBlock: some View {
        VStack(spacing: 2) {
            Text(iap.displayPrice)
                .font(.serif(40, .bold))
                .foregroundStyle(PaperTheme.inkPrimary)
            Text("one-time purchase")
                .font(.system(size: 13, weight: .semibold))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundStyle(PaperTheme.inkSecondary)
        }
    }

    private var cta: some View {
        Button {
            working = true
            Task { _ = try? await iap.purchase(); working = false }
        } label: {
            HStack(spacing: 10) {
                if working { ProgressView().tint(PaperTheme.scanButtonGlyph) }
                Text(working ? "Processing…" : "Go Pro")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(PaperTheme.scanButtonGlyph)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(PaperTheme.accent))
        }
        .buttonStyle(InkPressButtonStyle())
        .disabled(working)
    }

    private var legal: some View {
        VStack(spacing: 6) {
            Text("One-time purchase. No subscription, ever.")
                .font(.system(size: 13))
                .foregroundStyle(PaperTheme.inkSecondary)
            HStack(spacing: 16) {
                Link("Terms", destination: URL(string: "https://getscanlite.vercel.app/terms")!)
                Link("Privacy", destination: URL(string: "https://getscanlite.vercel.app/privacy")!)
            }
            .font(.system(size: 13, weight: .medium))
            .tint(PaperTheme.accent)
        }
        .padding(.top, 4)
    }
}
