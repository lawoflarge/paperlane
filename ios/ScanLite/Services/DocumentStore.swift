import Foundation
import SwiftData
import UIKit

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
        createdAt: Date = .now,
        ocrText: String = ""
    ) throws -> ScannedDocument {
        let fileName = "\(UUID().uuidString).pdf"
        try files.write(pdfData, fileName: fileName)
        let doc = ScannedDocument(
            title: title,
            createdAt: createdAt,
            pageCount: pageCount,
            fileName: fileName,
            fileSizeBytes: pdfData.count,
            ocrText: ocrText
        )
        context.insert(doc)
        try context.save()
        return doc
    }

    /// Persist a freshly-captured scan: run one on-device OCR pass to build a
    /// searchable PDF and index its text (free), then save. The text powers free
    /// in-document search and Pro text export.
    @discardableResult
    func saveScan(
        title: String,
        images: [UIImage],
        createdAt: Date = .now
    ) throws -> ScannedDocument {
        let result = OCRService().makeSearchable(images: images)
        return try save(
            title: title,
            pdfData: result.data,
            pageCount: images.count,
            createdAt: createdAt,
            ocrText: result.text
        )
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

    /// Replace a document's PDF bytes in place after a page edit (reorder/delete/
    /// append) and update its page count + size (free).
    func replace(_ doc: ScannedDocument, withData data: Data, pageCount: Int) throws {
        try files.write(data, fileName: doc.fileName)
        doc.pageCount = pageCount
        doc.fileSizeBytes = data.count
        try context.save()
    }

    /// Assign (or clear) a document's folder (free organisation).
    func setFolder(_ doc: ScannedDocument, folderID: UUID?) throws {
        doc.folderID = folderID
        try context.save()
    }

    @discardableResult
    func createFolder(name: String) throws -> Folder {
        let folder = Folder(name: name)
        context.insert(folder)
        try context.save()
        return folder
    }

    /// Delete a folder and un-file any documents that referenced it.
    func deleteFolder(_ folder: Folder) throws {
        let fid = folder.uuid
        let all = (try? context.fetch(FetchDescriptor<ScannedDocument>())) ?? []
        for doc in all where doc.folderID == fid { doc.folderID = nil }
        context.delete(folder)
        try context.save()
    }

    func delete(_ doc: ScannedDocument) throws {
        try? files.delete(fileName: doc.fileName)
        context.delete(doc)
        try context.save()
    }
}
