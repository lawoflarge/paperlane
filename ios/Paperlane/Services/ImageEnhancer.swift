import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// On-device page enhancement / colour modes (free). CoreImage only — the scan
/// never leaves the phone. `apply` returns a new image (or the original on failure).
struct ImageEnhancer {
    enum Mode: String, CaseIterable, Identifiable {
        case original
        case color          // brighten + gentle contrast/saturation
        case grayscale
        case blackWhite     // high-contrast document threshold
        case sharpen        // shadow/glare lift

        var id: String { rawValue }
        var label: String {
            switch self {
            case .original: return "Original"
            case .color: return "Color"
            case .grayscale: return "Gray"
            case .blackWhite: return "B&W"
            case .sharpen: return "Sharpen"
            }
        }
        var systemImage: String {
            switch self {
            case .original: return "photo"
            case .color: return "paintpalette"
            case .grayscale: return "circle.lefthalf.filled"
            case .blackWhite: return "circle.righthalf.filled"
            case .sharpen: return "wand.and.rays"
            }
        }
    }

    private let context = CIContext(options: nil)

    func apply(_ mode: Mode, to image: UIImage) -> UIImage {
        guard mode != .original, let input = CIImage(image: image) else { return image }
        let output: CIImage
        switch mode {
        case .original:
            output = input
        case .color:
            let f = CIFilter.colorControls()
            f.inputImage = input
            f.saturation = 1.1
            f.contrast = 1.15
            f.brightness = 0.02
            output = f.outputImage ?? input
        case .grayscale:
            let f = CIFilter.photoEffectMono()
            f.inputImage = input
            output = f.outputImage ?? input
        case .blackWhite:
            let mono = CIFilter.colorControls()
            mono.inputImage = input
            mono.saturation = 0
            mono.contrast = 1.7
            mono.brightness = 0.04
            output = mono.outputImage ?? input
        case .sharpen:
            let f = CIFilter.highlightShadowAdjust()
            f.inputImage = input
            f.shadowAmount = 1.0
            f.highlightAmount = 0.4
            output = f.outputImage ?? input
        }
        guard let cg = context.createCGImage(output, from: input.extent) else { return image }
        return UIImage(cgImage: cg, scale: image.scale, orientation: image.imageOrientation)
    }
}
