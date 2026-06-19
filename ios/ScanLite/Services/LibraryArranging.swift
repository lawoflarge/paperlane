import Foundation

/// How the library grid is ordered. Free organisation feature — no Pro gate.
enum DocumentSort: String, CaseIterable, Identifiable {
    case newest
    case oldest
    case nameAZ
    case largest

    var id: String { rawValue }

    var label: String {
        switch self {
        case .newest: return "Newest first"
        case .oldest: return "Oldest first"
        case .nameAZ: return "Name (A–Z)"
        case .largest: return "Largest first"
        }
    }

    var systemImage: String {
        switch self {
        case .newest: return "clock.arrow.circlepath"
        case .oldest: return "clock"
        case .nameAZ: return "textformat"
        case .largest: return "arrow.up.arrow.down"
        }
    }
}

/// Pure, dependency-free library arrangement: search-filter then sort, with
/// favourites always pinned to the top. Kept out of the view so it is unit-tested.
enum LibraryArranging {
    /// Filter `documents` by a case/diacritic-insensitive title query (empty query
    /// keeps all), then order by `sort` with favourites pinned ahead of the rest.
    static func arrange(_ documents: [ScannedDocument], sort: DocumentSort, query: String, folderID: UUID? = nil) -> [ScannedDocument] {
        let scoped = folderID == nil ? documents : documents.filter { $0.folderID == folderID }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = trimmed.isEmpty
            ? scoped
            : scoped.filter {
                $0.title.localizedStandardContains(trimmed)
                    || $0.ocrText.localizedStandardContains(trimmed)
            }

        return filtered.sorted { lhs, rhs in
            if lhs.isFavorite != rhs.isFavorite { return lhs.isFavorite }
            switch sort {
            case .newest: return lhs.createdAt > rhs.createdAt
            case .oldest: return lhs.createdAt < rhs.createdAt
            case .nameAZ: return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
            case .largest: return lhs.fileSizeBytes > rhs.fileSizeBytes
            }
        }
    }
}
