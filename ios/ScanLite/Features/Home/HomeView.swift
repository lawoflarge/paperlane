import SwiftUI

/// Phase 0 placeholder home screen. Replaced in Phase 1 with the Paper & Ink
/// design and the single giant Scan button (the <=1-tap-to-camera budget).
struct HomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("ScanLite")
                .font(.largeTitle.bold())
            Text("Scan to PDF")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
