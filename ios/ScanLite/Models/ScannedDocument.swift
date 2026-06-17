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

    init(
        title: String,
        createdAt: Date = .now,
        pageCount: Int,
        fileName: String,
        fileSizeBytes: Int,
        isFavorite: Bool = false
    ) {
        self.title = title
        self.createdAt = createdAt
        self.pageCount = pageCount
        self.fileName = fileName
        self.fileSizeBytes = fileSizeBytes
        self.isFavorite = isFavorite
    }
}
