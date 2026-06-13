import UIKit

/// Abstraction over the capture source. `VNDocumentCameraViewController` is
/// device-only (no Simulator), so the whole OCR → PDF → library pipeline depends
/// on this seam to stay testable with injected fixture images.
protocol ScanSource {
    func capture() async -> [UIImage]
}

/// Test / Simulator source that returns injected fixture images.
struct MockScanSource: ScanSource {
    let images: [UIImage]
    func capture() async -> [UIImage] { images }
}
