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

    /// Star / unstar a document (free). Favourites pin to the top of the library.
    func setFavorite(_ doc: ScannedDocument, _ isFavorite: Bool) throws {
        doc.isFavorite = isFavorite
        try context.save()
    }

    /// Duplicate a document (free): copy its PDF bytes to a new file + insert a record.
    @discardableResult
    func duplicate(_ doc: ScannedDocument) throws -> ScannedDocument {
        let data = try files.read(fileName: doc.fileName)
        let fileName = "\(UUID().uuidString).pdf"
        try files.write(data, fileName: fileName)
        let copy = ScannedDocument(
            title: "Copy of \(doc.title)",
            pageCount: doc.pageCount,
            fileName: fileName,
            fileSizeBytes: data.count
        )
        context.insert(copy)
        try context.save()
        return copy
    }

    /// Rotate every page of a document 90° clockwise, in place (free).
    func rotate(_ doc: ScannedDocument) throws {
        let data = try files.read(fileName: doc.fileName)
        guard let rotated = PDFRotator().rotated(data, clockwiseQuarterTurns: 1) else { return }
        try files.write(rotated, fileName: doc.fileName)
        doc.fileSizeBytes = rotated.count
        try context.save()
    }

    func delete(_ doc: ScannedDocument) throws {
        try? files.delete(fileName: doc.fileName)
        context.delete(doc)
        try context.save()
    }
}
