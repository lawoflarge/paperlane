import Testing
import SwiftData
import Foundation
@testable import ScanLite

@MainActor
@Suite(.serialized)
struct DocumentStoreTests {

    /// In-memory store for tests. Returns the container too so the caller keeps it
    /// alive for the whole test body (avoids any teardown race / use-after-free).
    private func makeStore() throws -> (store: DocumentStore, container: ModelContainer) {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: ScannedDocument.self, configurations: config)
        let files = DocumentFileStore(
            directory: URL.temporaryDirectory.appending(path: "scanlite-store-\(UUID().uuidString)")
        )
        return (DocumentStore(context: container.mainContext, files: files), container)
    }

    @Test func saveThenListReturnsDocument() throws {
        let (store, container) = try makeStore()
        try withExtendedLifetime(container) {
            let data = PDFAssembler().assemble(images: [ImageFixtures.page("1")])
            let doc = try store.save(title: "Receipt", pdfData: data, pageCount: 1)
            let all = try store.all()
            #expect(all.count == 1)
            #expect(all.first?.title == "Receipt")
            #expect(all.first?.pageCount == 1)
            #expect(doc.fileSizeBytes == data.count)
        }
    }

    @Test func renameUpdatesTitle() throws {
        let (store, container) = try makeStore()
        try withExtendedLifetime(container) {
            let data = PDFAssembler().assemble(images: [ImageFixtures.page("1")])
            let doc = try store.save(title: "Old", pdfData: data, pageCount: 1)
            try store.rename(doc, to: "New")
            #expect(try store.all().first?.title == "New")
        }
    }

    @Test func deleteRemovesFromLibraryAndDisk() throws {
        let (store, container) = try makeStore()
        try withExtendedLifetime(container) {
            let data = PDFAssembler().assemble(images: [ImageFixtures.page("1")])
            let doc = try store.save(title: "Temp", pdfData: data, pageCount: 1)
            let fileName = doc.fileName
            try store.delete(doc)
            #expect(try store.all().isEmpty)
            #expect(throws: (any Error).self) {
                try store.files.read(fileName: fileName)
            }
        }
    }
}
