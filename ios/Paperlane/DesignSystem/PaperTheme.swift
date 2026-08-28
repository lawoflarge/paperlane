import SwiftUI
import UIKit

/// "Paper & Ink" design tokens. One signature accent (warm stamp-ink vermilion),
/// warm paper surfaces, ink-black text. Light + dark resolved dynamically.
enum PaperTheme {
    static let surface         = Color.paper("FAF6EF", "15130F")
    static let card            = Color.paper("FFFDF8", "1E1B16")
    static let cardEdge        = Color.paper("EDE6D8", "2A261F")
    static let inkPrimary      = Color.paper("1A1714", "F2ECE1")
    static let inkSecondary    = Color.paper("5C554A", "A89E8E")
    static let inkTertiary     = Color.paper("9A9082", "6E665A")
    static let accent          = Color.paper("B4472B", "D9694A")
    static let accentWash      = Color.paper("B4472B1F", "D9694A2B")
    static let scanButtonFill  = Color.paper("1A1714", "F2ECE1")
    static let scanButtonGlyph = Color.paper("FAF6EF", "15130F")
    static let successLedger   = Color.paper("3E6B4F", "6FA882")
    static let separator       = Color.paper("E4DCCD", "2A261F")
    static let shadowAmbient   = Color.paper("46361F1A", "00000000")
}

extension Color {
    /// Dynamic light/dark color from 6- or 8-digit hex strings.
    static func paper(_ light: String, _ dark: String) -> Color {
        Color(UIColor { trait in
            UIColor(hexString: trait.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

extension UIColor {
    convenience init(hexString: String) {
        var s = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: s).scanHexInt64(&value)
        let r, g, b, a: CGFloat
        if s.count == 8 {
            r = CGFloat((value & 0xFF00_0000) >> 24) / 255
            g = CGFloat((value & 0x00FF_0000) >> 16) / 255
            b = CGFloat((value & 0x0000_FF00) >> 8) / 255
            a = CGFloat(value & 0x0000_00FF) / 255
        } else {
            r = CGFloat((value & 0xFF0000) >> 16) / 255
            g = CGFloat((value & 0x00FF00) >> 8) / 255
            b = CGFloat(value & 0x0000FF) / 255
            a = 1
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}

extension Font {
    /// New York (SF Serif) at a given size/weight — the editorial voice.
    static func serif(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}
