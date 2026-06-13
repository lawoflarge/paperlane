import SwiftUI
import SwiftData
import PDFKit

/// Pro "combine" flow: multi-select documents and merge them into one PDF.
struct MergeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ScannedDocument.createdAt, order: .reverse) private var documents: [ScannedDocument]
    @State private var selected: Set<PersistentIdentifier> = []

    private let files = DocumentFileStore.defaultStore()

    var body: some View {
        NavigationStack {
            List {
                ForEach(documents) { doc in
                    HStack(spacing: 12) {
                        Image(systemName: selected.contains(doc.persistentModelID) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 20))
                            .foregroundStyle(selected.contains(doc.persistentModelID) ? PaperTheme.accent : PaperTheme.inkTertiary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(doc.title).font(.serif(16, .medium)).foregroundStyle(PaperTheme.inkPrimary).lineLimit(1)
                            Text("\(doc.pageCount) page\(doc.pageCount == 1 ? "" : "s")")
                                .font(.system(size: 12).monospacedDigit())
                                .foregroundStyle(PaperTheme.inkSecondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { toggle(doc) }
                }
            }
            .navigationTitle("Combine PDFs")
            .navigationBarTitleDisplayMode(.inline)
            .tint(PaperTheme.accent)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Merge (\(selected.count))") { merge() }
                        .disabled(selected.count < 2)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func toggle(_ doc: ScannedDocument) {
        if selected.contains(doc.persistentModelID) {
            selected.remove(doc.persistentModelID)
        } else {
            selected.insert(doc.persistentModelID)
        }
    }

    private func merge() {
        let datas = documents
            .filter { selected.contains($0.persistentModelID) }
            .compactMap { try? files.read(fileName: $0.fileName) }
        guard let merged = PDFMerger().merge(datas),
              let pdf = PDFDocument(data: merged) else { return }
        _ = try? DocumentStore(context: context).save(
            title: "Combined " + Samples.autoName(),
            pdfData: merged,
            pageCount: pdf.pageCount
        )
        dismiss()
    }
}
