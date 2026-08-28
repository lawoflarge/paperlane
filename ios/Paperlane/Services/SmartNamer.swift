import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// On-device AI document naming from OCR content (Pro). Uses Apple FoundationModels
/// (iOS 26, runs on-device — zero server cost) when available; otherwise falls back
/// to the heuristic `AutoNamer`. Never sends anything off-device.
enum SmartNamer {
    static var isAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26, *) {
            if case .available = SystemLanguageModel.default.availability { return true }
        }
        #endif
        return false
    }

    static func suggest(ocrText: String, date: Date = .now) async -> String {
        let fallback = AutoNamer.suggest(ocrText: ocrText, date: date)
        let trimmed = ocrText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return fallback }

        #if canImport(FoundationModels)
        if #available(iOS 26, *), case .available = SystemLanguageModel.default.availability {
            do {
                let session = LanguageModelSession(instructions: """
                    You name scanned documents. Given the recognized text, return a short,
                    descriptive file name (max 6 words): include the document type (e.g.
                    Invoice, Receipt, Lab Report, Letter) and the most identifying detail
                    (company, person, or date) if present. No file extension, no quotes.
                    """)
                let snippet = String(trimmed.prefix(1500))
                let response = try await session.respond(to: "Text:\n\(snippet)", generating: SuggestedName.self)
                let name = response.content.name.trimmingCharacters(in: .whitespacesAndNewlines)
                return name.isEmpty ? fallback : name
            } catch {
                return fallback
            }
        }
        #endif
        return fallback
    }
}

#if canImport(FoundationModels)
@available(iOS 26, *)
@Generable(description: "A short, descriptive file name for a scanned document")
struct SuggestedName {
    @Guide(description: "A concise document name, max 6 words, no file extension")
    var name: String
}
#endif
