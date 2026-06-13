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

    init(
        title: String,
        createdAt: Date = .now,
        pageCount: Int,
        fileName: String,
        fileSizeBytes: Int
    ) {
        self.title = title
        self.createdAt = createdAt
        self.pageCount = pageCount
        self.fileName = fileName
        self.fileSizeBytes = fileSizeBytes
    }
}
