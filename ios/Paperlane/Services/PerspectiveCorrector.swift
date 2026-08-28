import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// Applies a perspective correction to an image given a crop quad (free).
/// On-device CoreImage; returns the original image on failure.
struct PerspectiveCorrector {
    private let context = CIContext(options: nil)

    /// `quad` corners are normalized (0...1), origin TOP-LEFT (UI convention).
    func correct(_ image: UIImage, quad: Quad) -> UIImage {
        guard let ci = CIImage(image: image) else { return image }
        let width = ci.extent.width, height = ci.extent.height
        func point(_ p: CGPoint) -> CGPoint {
            CGPoint(x: p.x * width, y: (1 - p.y) * height)   // flip to CI bottom-left origin
        }
        let filter = CIFilter.perspectiveCorrection()
        filter.inputImage = ci
        filter.topLeft = point(quad.topLeft)
        filter.topRight = point(quad.topRight)
        filter.bottomRight = point(quad.bottomRight)
        filter.bottomLeft = point(quad.bottomLeft)
        guard let output = filter.outputImage,
              let cg = context.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
    }
}
