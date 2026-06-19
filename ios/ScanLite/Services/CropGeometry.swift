import CoreGraphics

/// A quadrilateral of 4 corner points in normalized (0...1) image space, origin TL.
struct Quad: Equatable {
    var topLeft: CGPoint
    var topRight: CGPoint
    var bottomRight: CGPoint
    var bottomLeft: CGPoint
}

/// Pure crop-quad helpers (free): the default full-image quad, clamping into the
/// unit square, and ordering 4 arbitrary corners into TL/TR/BR/BL.
enum CropGeometry {
    static var full: Quad {
        Quad(topLeft: CGPoint(x: 0, y: 0), topRight: CGPoint(x: 1, y: 0),
             bottomRight: CGPoint(x: 1, y: 1), bottomLeft: CGPoint(x: 0, y: 1))
    }

    static func clamped(_ quad: Quad) -> Quad {
        func clamp(_ p: CGPoint) -> CGPoint {
            CGPoint(x: min(max(p.x, 0), 1), y: min(max(p.y, 0), 1))
        }
        return Quad(topLeft: clamp(quad.topLeft), topRight: clamp(quad.topRight),
                    bottomRight: clamp(quad.bottomRight), bottomLeft: clamp(quad.bottomLeft))
    }

    static func ordered(_ points: [CGPoint]) -> Quad? {
        guard points.count == 4 else { return nil }
        let byY = points.sorted { $0.y < $1.y }
        let top = Array(byY.prefix(2)).sorted { $0.x < $1.x }
        let bottom = Array(byY.suffix(2)).sorted { $0.x < $1.x }
        return Quad(topLeft: top[0], topRight: top[1], bottomRight: bottom[1], bottomLeft: bottom[0])
    }
}
