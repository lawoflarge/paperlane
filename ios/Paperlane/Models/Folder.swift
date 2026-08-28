import Foundation
import SwiftData

/// A user-created folder for organising the library (free feature). Identified by
/// a stable `uuid` (not a `.unique` constraint, so it stays CloudKit-compatible);
/// documents reference it via `ScannedDocument.folderID`.
@Model
final class Folder {
    /// Stable cross-reference id (matched by `ScannedDocument.folderID`). Defaulted
    /// for migration-safety and CloudKit (which forbids unique constraints).
    var uuid: UUID = UUID()
    var name: String = ""
    var createdAt: Date = Date.now
    /// 6-digit hex accent used for the folder chip.
    var colorHex: String = "B4472B"

    init(name: String, uuid: UUID = UUID(), createdAt: Date = .now, colorHex: String = "B4472B") {
        self.uuid = uuid
        self.name = name
        self.createdAt = createdAt
        self.colorHex = colorHex
    }
}
