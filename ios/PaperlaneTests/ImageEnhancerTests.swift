import Testing
import UIKit
@testable import Paperlane

struct ImageEnhancerTests {

    /// Average the whole image down to one pixel and read its RGB (alpha-aware).
    private func averageRGB(_ image: UIImage) -> (r: CGFloat, g: CGFloat, b: CGFloat)? {
        guard let cg = image.cgImage else { return nil }
        var px = [UInt8](repeating: 0, count: 4)
        let space = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: &px, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }
        ctx.interpolationQuality = .medium
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return (CGFloat(px[0]) / 255, CGFloat(px[1]) / 255, CGFloat(px[2]) / 255)
    }

    @Test func allModesPreservePixelSize() {
        let image = ImageFixtures.page("DOC", size: CGSize(width: 300, height: 400))
        for mode in ImageEnhancer.Mode.allCases {
            let out = ImageEnhancer().apply(mode, to: image)
            #expect(out.size.width == image.size.width)
            #expect(out.size.height == image.size.height)
        }
    }

    @Test func grayscaleDesaturatesAColouredImage() {
        let red = ImageFixtures.page("", size: CGSize(width: 100, height: 100), background: .red)
        let gray = ImageEnhancer().apply(.grayscale, to: red)
        guard let rgb = averageRGB(gray) else { Issue.record("no pixel data"); return }
        #expect(abs(rgb.r - rgb.g) < 0.12)   // mono → R≈G≈B
        #expect(abs(rgb.g - rgb.b) < 0.12)
    }

    @Test func originalReturnsSameSizeImage() {
        let image = ImageFixtures.page("X", size: CGSize(width: 120, height: 90))
        let out = ImageEnhancer().apply(.original, to: image)
        #expect(out.size == image.size)
    }
}
