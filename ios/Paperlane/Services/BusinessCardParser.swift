import Foundation

/// Contact details parsed from a business card's OCR text.
struct ParsedContact: Equatable {
    var fullName: String?
    var organization: String?
    var phone: String?
    var email: String?
    var hasAnything: Bool { fullName != nil || organization != nil || phone != nil || email != nil }
}

/// Heuristic on-device parser: OCR text → contact fields (Pro). Pure + deterministic.
enum BusinessCardParser {
    static func parse(ocrText: String) -> ParsedContact {
        let lines = ocrText
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        var contact = ParsedContact()
        contact.email = firstMatch(in: ocrText, pattern: #"[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}"#)
        contact.phone = firstMatch(in: ocrText, pattern: #"\+?\d[\d\s().\-]{6,}\d"#)?
            .trimmingCharacters(in: .whitespaces)
        contact.fullName = lines.first(where: looksLikeName)
        contact.organization = lines.first(where: looksLikeOrg)
        return contact
    }

    private static func looksLikeName(_ line: String) -> Bool {
        // Two to four capitalized words, no digits or "@".
        if line.contains("@") || line.rangeOfCharacter(from: .decimalDigits) != nil { return false }
        let words = line.split(separator: " ")
        guard words.count >= 2, words.count <= 4 else { return false }
        return words.allSatisfy { word in
            guard let first = word.first else { return false }
            return first.isUppercase && word.dropFirst().allSatisfy { $0.isLowercase || $0 == "." || $0 == "'" }
        }
    }

    private static func looksLikeOrg(_ line: String) -> Bool {
        let markers = ["Inc", "LLC", "Ltd", "GmbH", "Corp", "Co.", "Company", "Group", "Studio", "Labs", "AG", "SaaS"]
        return markers.contains { line.localizedCaseInsensitiveContains($0) }
    }

    private static func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              let r = Range(match.range, in: text) else { return nil }
        return String(text[r])
    }
}
