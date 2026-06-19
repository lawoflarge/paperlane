import SwiftUI
import SwiftData
import PDFKit
import PhotosUI

/// Page-level editing (free): reorder by drag, swipe to delete, add a page from
/// Photos. Edits apply to the document's PDF bytes via `PDFPageEditor` and persist
/// through `DocumentStore.replace`.
struct PageManagerView: View {
    let document: ScannedDocument
    let files: DocumentFileStore
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var pages: [UIImage] = []
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, image in
                    HStack(spacing: 14) {
                        Image(uiImage: image)
                            .resizable().scaledToFit()
                            .frame(width: 52, height: 70)
                            .background(PaperTheme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(PaperTheme.cardEdge, lineWidth: 0.5))
                        Text("Page \(index + 1)")
                            .font(.system(size: 15)).foregroundStyle(PaperTheme.inkPrimary)
                        Spacer()
                    }
                }
                .onMove(perform: move)
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            .navigationTitle("Pages")
            .navigationBarTitleDisplayMode(.inline)
            .tint(PaperTheme.accent)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { EditButton() }
                ToolbarItem(placement: .bottomBar) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label("Add page", systemImage: "plus")
                    }
                }
            }
            .onAppear(perform: loadThumbnails)
            .onChange(of: photoItem) { _, item in addPage(item) }
        }
    }

    private func loadThumbnails() {
        guard let data = try? files.read(fileName: document.fileName),
              let pdf = PDFDocument(data: data) else { return }
        pages = (0..<pdf.pageCount).compactMap { pdf.page(at: $0) }
            .map { $0.thumbnail(of: CGSize(width: 160, height: 220), for: .mediaBox) }
    }

    private func move(from source: IndexSet, to destination: Int) {
        guard let from = source.first,
              let data = try? files.read(fileName: document.fileName) else { return }
        let toIndex = from < destination ? destination - 1 : destination
        guard let newData = PDFPageEditor().reorder(data, from: from, to: toIndex),
              let pdf = PDFDocument(data: newData) else { return }
        persist(newData, pageCount: pdf.pageCount)
        pages.move(fromOffsets: source, toOffset: destination)
    }

    private func delete(_ offsets: IndexSet) {
        guard let index = offsets.first,
              let data = try? files.read(fileName: document.fileName),
              let newData = PDFPageEditor().deletePage(data, at: index),
              let pdf = PDFDocument(data: newData) else { return }
        persist(newData, pageCount: pdf.pageCount)
        pages.remove(atOffsets: offsets)
    }

    private func addPage(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let raw = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: raw),
                  let base = try? files.read(fileName: document.fileName) else { return }
            let pageData = PDFAssembler().assemble(images: [image])
            guard let newData = PDFPageEditor().append(pageData, to: base),
                  let pdf = PDFDocument(data: newData) else { return }
            persist(newData, pageCount: pdf.pageCount)
            loadThumbnails()
            photoItem = nil
        }
    }

    private func persist(_ data: Data, pageCount: Int) {
        try? DocumentStore(context: context).replace(document, withData: data, pageCount: pageCount)
    }
}
