import Testing
import UIKit
@testable import ScanLite

struct PerspectiveCorrectorTests {
    @Test func fullQuadReturnsRoughlySameSize() {
        let image = ImageFixtures.page("DOC", size: CGSize(width: 400, height: 600))
        let out = PerspectiveCorrector().correct(image, quad: CropGeometry.full)
        #expect(abs(out.size.width - image.size.width) <= 2)
        #expect(abs(out.size.height - image.size.height) <= 2)
    }

    @Test func insetQuadProducesSmallerImage() {
        let image = ImageFixtures.page("DOC", size: CGSize(width: 400, height: 600))
        let inset = Quad(topLeft: CGPoint(x: 0.1, y: 0.1), topRight: CGPoint(x: 0.9, y: 0.1),
                         bottomRight: CGPoint(x: 0.9, y: 0.9), bottomLeft: CGPoint(x: 0.1, y: 0.9))
        let out = PerspectiveCorrector().correct(image, quad: inset)
        #expect(out.size.width < image.size.width)
        #expect(out.size.width > 0)
    }
}
