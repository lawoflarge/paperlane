import Testing
import Foundation
@testable import ScanLite

struct LibraryArrangingTests {

    private func doc(_ title: String, daysAgo: Int = 0, size: Int = 1000, favorite: Bool = false, ocrText: String = "") -> ScannedDocument {
        ScannedDocument(
            title: title,
            createdAt: Date(timeIntervalSince1970: 1_000_000 - Double(daysAgo) * 86_400),
            pageCount: 1,
            fileName: "\(title).pdf",
            fileSizeBytes: size,
            isFavorite: favorite,
            ocrText: ocrText
        )
    }

    @Test func queryMatchesOcrTextNotJustTitle() {
        let docs = [
            doc("Untitled A", ocrText: "Quarterly revenue report"),
            doc("Untitled B", ocrText: "Grocery shopping list")
        ]
        let result = LibraryArranging.arrange(docs, sort: .newest, query: "revenue")
        #expect(result.map(\.title) == ["Untitled A"])
    }

    @Test func newestFirstOrdersByCreatedAtDescending() {
        let docs = [doc("A", daysAgo: 2), doc("B", daysAgo: 0), doc("C", daysAgo: 1)]
        let result = LibraryArranging.arrange(docs, sort: .newest, query: "")
        #expect(result.map(\.title) == ["B", "C", "A"])
    }

    @Test func oldestFirstOrdersByCreatedAtAscending() {
        let docs = [doc("A", daysAgo: 2), doc("B", daysAgo: 0), doc("C", daysAgo: 1)]
        let result = LibraryArranging.arrange(docs, sort: .oldest, query: "")
        #expect(result.map(\.title) == ["A", "C", "B"])
    }

    @Test func nameAZSortsCaseInsensitively() {
        let docs = [doc("banana"), doc("Apple"), doc("cherry")]
        let result = LibraryArranging.arrange(docs, sort: .nameAZ, query: "")
        #expect(result.map(\.title) == ["Apple", "banana", "cherry"])
    }

    @Test func largestFirstOrdersByFileSizeDescending() {
        let docs = [doc("A", size: 100), doc("B", size: 9000), doc("C", size: 500)]
        let result = LibraryArranging.arrange(docs, sort: .largest, query: "")
        #expect(result.map(\.title) == ["B", "C", "A"])
    }

    @Test func queryFiltersByTitleCaseInsensitively() {
        let docs = [doc("Invoice March"), doc("Receipt"), doc("invoice April")]
        let result = LibraryArranging.arrange(docs, sort: .nameAZ, query: "invoice")
        #expect(Set(result.map(\.title)) == ["Invoice March", "invoice April"])
    }

    @Test func emptyQueryKeepsAll() {
        let docs = [doc("A"), doc("B")]
        #expect(LibraryArranging.arrange(docs, sort: .nameAZ, query: "").count == 2)
    }

    @Test func favoritesPinToTopRegardlessOfSort() {
        let docs = [
            doc("Apple", daysAgo: 0, favorite: false),
            doc("Zebra", daysAgo: 5, favorite: true)
        ]
        // Newest-first alone would put Apple first; the favourite Zebra pins ahead.
        let result = LibraryArranging.arrange(docs, sort: .newest, query: "")
        #expect(result.map(\.title) == ["Zebra", "Apple"])
    }

    @Test func favoritesKeepInternalSortOrder() {
        let docs = [
            doc("Fav-old", daysAgo: 5, favorite: true),
            doc("Fav-new", daysAgo: 1, favorite: true),
            doc("Plain", daysAgo: 0, favorite: false)
        ]
        let result = LibraryArranging.arrange(docs, sort: .newest, query: "")
        #expect(result.map(\.title) == ["Fav-new", "Fav-old", "Plain"])
    }
}
