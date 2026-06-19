import Testing
import CoreGraphics
@testable import ScanLite

struct CropGeometryTests {
    @Test func ordersArbitraryCornersIntoTLTRBRBL() {
        let points = [
            CGPoint(x: 0.9, y: 0.1),   // TR
            CGPoint(x: 0.1, y: 0.9),   // BL
            CGPoint(x: 0.1, y: 0.1),   // TL
            CGPoint(x: 0.9, y: 0.9)    // BR
        ]
        let quad = CropGeometry.ordered(points)
        #expect(quad?.topLeft == CGPoint(x: 0.1, y: 0.1))
        #expect(quad?.topRight == CGPoint(x: 0.9, y: 0.1))
        #expect(quad?.bottomRight == CGPoint(x: 0.9, y: 0.9))
        #expect(quad?.bottomLeft == CGPoint(x: 0.1, y: 0.9))
    }

    @Test func clampsOutOfRangeCornersIntoUnitSquare() {
        let quad = Quad(topLeft: CGPoint(x: -0.2, y: -0.5), topRight: CGPoint(x: 1.4, y: 0),
                        bottomRight: CGPoint(x: 2, y: 2), bottomLeft: CGPoint(x: 0, y: 1.1))
        let clamped = CropGeometry.clamped(quad)
        #expect(clamped.topLeft == CGPoint(x: 0, y: 0))
        #expect(clamped.topRight == CGPoint(x: 1, y: 0))
        #expect(clamped.bottomRight == CGPoint(x: 1, y: 1))
        #expect(clamped.bottomLeft == CGPoint(x: 0, y: 1))
    }

    @Test func orderedRejectsWrongCount() {
        #expect(CropGeometry.ordered([CGPoint(x: 0, y: 0)]) == nil)
    }
}
