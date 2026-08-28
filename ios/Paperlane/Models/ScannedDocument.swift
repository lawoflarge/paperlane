import Foundation
import SwiftData

/// A scanned document in the local-first library. The on-device store is the
/// canonical source of truth (competitor lesson: cloud-sync loss strands users).
/// The PDF bytes live on disk; this model holds metadata + the file reference.
@Model
final class ScannedDocument {
    var title: String
    var createdAt: Date
    var pageCount: Int
    /// PDF file name within the documents directory (see `DocumentFileStore`).
    var fileName: String
    var fileSizeBytes: Int
    /// User-starred documents pin to the top of the library. Defaulted so SwiftData
    /// performs a lightweight migration for any pre-existing records.
    var isFavorite: Bool = false
    /// Recognized text from the on-device OCR pass at save time. Powers free
    /// in-document search and is the source for Pro text export. Defaulted so
    /// SwiftData performs a lightweight migration for pre-v2 records.
    var ocrText: String = ""
    /// Optional folder assignment (free organisation). Matches `Folder.uuid`;
    /// `nil` = unfiled. Defaulted/optional → migration-safe + CloudKit-ready.
    var folderID: UUID? = nil
    /// Free-form tags (free organisation).
    var tags: [String] = []

    init(
        title: String,
        createdAt: Date = .now,
        pageCount: Int,
        fileName: String,
        fileSizeBytes: Int,
        isFavorite: Bool = false,
        ocrText: String = "",
        folderID: UUID? = nil,
        tags: [String] = []
    ) {
        self.title = title
        self.createdAt = createdAt
        self.pageCount = pageCount
        self.fileName = fileName
        self.fileSizeBytes = fileSizeBytes
        self.isFavorite = isFavorite
        self.ocrText = ocrText
        self.folderID = folderID
        self.tags = tags
    }
}
