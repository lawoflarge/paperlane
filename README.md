# Paperlane

One-tap PDF document scanner for iOS. Free, no-login, no-watermark, no subscription. Exports clean, searchable PDFs forever.

**The wedge:** Adobe Scan / Scanner Pro charge $10-20/mo for tech Apple ships for free (VisionKit edge-detect, Vision OCR, PDFKit encryption). Paperlane ships that and charges **once** (~5 EUR one-time unlock).

## Free vs Pro
- **Free (best-in-class):** unlimited scans, auto edge-detect + perspective correction, real multi-page PDF export, share sheet, local library, **no watermark ever**, banner ads.
- **Pro (one-time ~5 EUR):** on-device OCR searchable-text layer, batch-combine/merge, JPG/PNG export, password-protect, custom naming, **removes all ads**.

## Monorepo
- `ios/`: Swift 6 / SwiftUI / iOS 17+ app (xcodegen, Swift Testing). Bundle `de.levinschwab.scanlite`.
- `web/`: Vercel-hosted marketing + legal pages (`getpaperlane.vercel.app`).
- `docs/`: build plan & specs.

Stack: VisionKit (`VNDocumentCameraViewController`), Vision (`VNRecognizeTextRequest`), PDFKit, ImageIO, SwiftData, StoreKit 2, GoogleMobileAds v13. No backend, no login, 100% on-device.

## Build
```
cd ios && xcodegen generate && open Paperlane.xcodeproj
```
