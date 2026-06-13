import Foundation
import SwiftData

/// SwiftData-backed library CRUD. `@MainActor` because `ModelContext` is not Sendable.
/// Pairs the metadata model with on-disk PDF bytes via `DocumentFileStore`.
@MainActor
struct DocumentStore {
    let context: ModelContext
    let files: DocumentFileStore

    init(context: ModelContext, files: DocumentFileStore = .defaultStore()) {
        self.context = context
        self.files = files
    }

    /// Persist a freshly-assembled PDF: write the bytes to disk, then insert the model.
    @discardableResult
    func save(
        title: String,
        pdfData: Data,
        pageCount: Int,
        createdAt: Date = .now
    ) throws -> ScannedDocument {
        let fileName = "\(UUID().uuidString).pdf"
        try files.write(pdfData, fileName: fileName)
        let doc = ScannedDocument(
            title: title,
            createdAt: createdAt,
            pageCount: pageCount,
            fileName: fileName,
            fileSizeBytes: pdfData.count
        )
        context.insert(doc)
        try context.save()
        return doc
    }

    /// All documents, newest first.
    func all() throws -> [ScannedDocument] {
        let descriptor = FetchDescriptor<ScannedDocument>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    func rename(_ doc: ScannedDocument, to newTitle: String) throws {
        doc.title = newTitle
        try context.save()
    }

    func delete(_ doc: ScannedDocument) throws {
        try? files.delete(fileName: doc.fileName)
        context.delete(doc)
        try context.save()
    }
}
