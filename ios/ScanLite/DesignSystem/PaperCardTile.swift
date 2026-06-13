import SwiftUI
import PDFKit

/// A library document tile that reads as a physical sheet: paper fill, cut-edge
/// hairline, warm desk shadow, a dog-eared corner, and the deskewed page thumbnail.
struct PaperCardTile: View {
    let title: String
    let pageCount: Int
    let createdAt: Date
    let fileSizeBytes: Int
    let pdfURL: URL

    @State private var thumb: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(PaperTheme.card)
                .aspectRatio(0.78, contentMode: .fit)
                .overlay {
                    if let thumb {
                        Image(uiImage: thumb).resizable().scaledToFill()
                    } else {
                        Image(systemName: "doc.text")
                            .font(.system(size: 34))
                            .foregroundStyle(PaperTheme.inkTertiary)
                    }
                }
                .clipped()
                .overlay(alignment: .topTrailing) { dogEar }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.serif(16, .medium))
                    .foregroundStyle(PaperTheme.inkPrimary)
                    .lineLimit(1)
                Text(metadata)
                    .font(.system(size: 12).monospacedDigit())
                    .foregroundStyle(PaperTheme.inkSecondary)
                    .lineLimit(1)
            }
            .padding(10)
        }
        .background(PaperTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(PaperTheme.cardEdge, lineWidth: 0.5)
        )
        .shadow(color: PaperTheme.shadowAmbient, radius: 10, x: 0, y: 6)
        .task { if thumb == nil { thumb = loadThumb() } }
    }

    private var dogEar: some View {
        Path { p in
            p.move(to: CGPoint(x: 20, y: 0))
            p.addLine(to: CGPoint(x: 20, y: 20))
            p.addLine(to: CGPoint(x: 0, y: 0))
            p.closeSubpath()
        }
        .fill(PaperTheme.surface)
        .frame(width: 20, height: 20)
    }

    private var metadata: String {
        let date = createdAt.formatted(date: .abbreviated, time: .omitted)
        let size = ByteCountFormatter.string(fromByteCount: Int64(fileSizeBytes), countStyle: .file)
        return "\(pageCount) page\(pageCount == 1 ? "" : "s") · \(size) · \(date)"
    }

    private func loadThumb() -> UIImage? {
        guard let data = try? Data(contentsOf: pdfURL),
              let doc = PDFDocument(data: data),
              let page = doc.page(at: 0) else { return nil }
        return page.thumbnail(of: CGSize(width: 320, height: 410), for: .mediaBox)
    }
}
