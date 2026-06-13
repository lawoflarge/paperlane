import Foundation

/// Local-first PDF file storage. The on-device library is the source of truth;
/// iCloud / cloud export is an explicit, opt-in user action (never the only copy).
/// Injectable directory so the whole pipeline is testable on a temp folder.
struct DocumentFileStore {
    let directory: URL

    init(directory: URL) {
        self.directory = directory
    }

    /// The production store under Application Support.
    static func defaultStore() -> DocumentFileStore {
        let base = URL.applicationSupportDirectory
            .appending(path: "ScannedDocuments", directoryHint: .isDirectory)
        return DocumentFileStore(directory: base)
    }

    func fileURL(_ fileName: String) -> URL {
        directory.appending(path: fileName, directoryHint: .notDirectory)
    }

    private func ensureDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    @discardableResult
    func write(_ data: Data, fileName: String) throws -> URL {
        try ensureDirectory()
        let url = fileURL(fileName)
        try data.write(to: url, options: .atomic)
        return url
    }

    func read(fileName: String) throws -> Data {
        try Data(contentsOf: fileURL(fileName))
    }

    func delete(fileName: String) throws {
        let url = fileURL(fileName)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
    }
}
