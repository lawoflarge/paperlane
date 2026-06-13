import Testing
import Foundation
@testable import ScanLite

struct DocumentFileStoreTests {

    private func tempStore() -> DocumentFileStore {
        let dir = URL.temporaryDirectory.appending(path: "scanlite-files-\(UUID().uuidString)")
        return DocumentFileStore(directory: dir)
    }

    @Test func writeThenReadRoundTrips() throws {
        let store = tempStore()
        let data = Data("hello pdf".utf8)
        try store.write(data, fileName: "a.pdf")
        #expect(try store.read(fileName: "a.pdf") == data)
    }

    @Test func deleteRemovesFile() throws {
        let store = tempStore()
        try store.write(Data([1, 2, 3]), fileName: "b.pdf")
        try store.delete(fileName: "b.pdf")
        #expect(throws: (any Error).self) {
            try store.read(fileName: "b.pdf")
        }
    }
}
