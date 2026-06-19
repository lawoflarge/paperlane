import SwiftUI
import SwiftData

/// Post-capture review: pick an enhancement filter (applied to every page), see a
/// live preview, then save. On save the pages are OCR'd once (free searchable layer
/// + indexed text) and auto-named from the first recognized line. Free.
struct ReviewScanView: View {
    let images: [UIImage]
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var mode: ImageEnhancer.Mode = .original
    @State private var saving = false
    private let enhancer = ImageEnhancer()

    private var preview: UIImage { enhancer.apply(mode, to: images.first ?? UIImage()) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(uiImage: preview)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(12)
                    .background(PaperTheme.card, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(PaperTheme.cardEdge, lineWidth: 0.5))
                    .padding(.horizontal, 20)

                filterStrip

                Text("\(images.count) page\(images.count == 1 ? "" : "s")")
                    .font(.system(size: 13).monospacedDigit())
                    .foregroundStyle(PaperTheme.inkSecondary)
                    .padding(.bottom, 8)
            }
            .padding(.top, 12)
            .background(PaperTheme.surface.ignoresSafeArea().paperGrain())
            .navigationTitle("Review scan")
            .navigationBarTitleDisplayMode(.inline)
            .tint(PaperTheme.accent)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() }.disabled(saving) }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }.fontWeight(.semibold).disabled(saving)
                }
            }
            .overlay {
                if saving {
                    ProgressView("Saving…")
                        .padding(22)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    private var filterStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(ImageEnhancer.Mode.allCases) { option in
                    Button { mode = option } label: {
                        VStack(spacing: 6) {
                            Image(systemName: option.systemImage).font(.system(size: 19))
                            Text(option.label).font(.system(size: 11, weight: .medium))
                        }
                        .foregroundStyle(mode == option ? PaperTheme.accent : PaperTheme.inkSecondary)
                        .frame(width: 66, height: 62)
                        .background(mode == option ? PaperTheme.accentWash : PaperTheme.card,
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(mode == option ? PaperTheme.accent : PaperTheme.cardEdge,
                                          lineWidth: mode == option ? 1 : 0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func save() {
        saving = true
        let mode = self.mode
        let images = self.images
        Task {
            await Task.yield()
            let enhanced = images.map { enhancer.apply(mode, to: $0) }
            let result = OCRService().makeSearchable(images: enhanced)
            let name = AutoNamer.suggest(ocrText: result.text)
            _ = try? DocumentStore(context: context).save(
                title: name,
                pdfData: result.data,
                pageCount: enhanced.count,
                ocrText: result.text
            )
            saving = false
            dismiss()
        }
    }
}
