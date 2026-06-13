import ImageIO
import UniformTypeIdentifiers
import UIKit

/// Exports a page image as JPG or PNG via ImageIO (Pro "export as image" feature).
struct ImageExporter {
    enum Format {
        case jpeg
        case png
        var utType: UTType { self == .jpeg ? .jpeg : .png }
    }

    func export(_ image: UIImage, as format: Format, quality: CGFloat = 0.8) -> Data? {
        guard let cgImage = image.cgImage else { return nil }
        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data, format.utType.identifier as CFString, 1, nil
        ) else { return nil }
        let options = [kCGImageDestinationLossyCompressionQuality: quality] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return data as Data
    }
}
