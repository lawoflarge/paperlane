import SwiftUI
import PDFKit

/// Full PDF preview with share + Pro actions (OCR, image export, password).
/// Every Pro entry point routes a non-Pro user to the paywall — never a no-op.
struct DocumentPreviewView: View {
    let document: ScannedDocument
    let files: DocumentFileStore
    @Environment(IAPManager.self) private var iap
    @Environment(\.dismiss) private var dismiss

    @State private var showShare = false
    @State private var showPaywall = false
    @State private var working = false
    @State private var reloadToken = UUID()
    @State private var shareItem: ShareItem?
    @State private var askPassword = false
    @State private var password = ""

    private var url: URL { files.fileURL(document.fileName) }

    var body: some View {
        NavigationStack {
            ZStack {
                PDFKitView(url: url)
                    .id(reloadToken)
                    .ignoresSafeArea(edges: .bottom)
                    .background(PaperTheme.surface)
                if working {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView("Working…").padding(20)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .navigationTitle(document.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Done") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showShare = true } label: { Image(systemName: "square.and.arrow.up") }
                }
                ToolbarItem(placement: .topBarTrailing) { proMenu }
            }
            .tint(PaperTheme.accent)
            .sheet(isPresented: $showShare) { ShareSheet(items: [url]) }
            .sheet(item: $shareItem) { item in ShareSheet(items: [item.url]) }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .alert("Set a password", isPresented: $askPassword) {
                SecureField("Password", text: $password)
                Button("Protect") { runEncrypt() }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var proMenu: some View {
        Menu {
            Button { gated { makeSearchable() } } label: { Label("Make Searchable (OCR)", systemImage: "text.viewfinder") }
            Button { gated { export(.jpeg) } } label: { Label("Export as JPG", systemImage: "photo") }
            Button { gated { export(.png) } } label: { Label("Export as PNG", systemImage: "photo.on.rectangle") }
            Button { gated { askPassword = true } } label: { Label("Password Protect", systemImage: "lock") }
        } label: {
            Image(systemName: "wand.and.stars")
        }
    }

    // MARK: - Pro gate

    private func gated(_ action: () -> Void) {
        if iap.isPro { action() } else { showPaywall = true }
    }

    private func makeSearchable() {
        working = true
        Task {
            await Task.yield()
            _ = ProDocumentActions(files: files).makeSearchable(document)
            reloadToken = UUID()
            working = false
        }
    }

    private func export(_ format: ImageExporter.Format) {
        guard let data = ProDocumentActions(files: files).exportImage(document, format: format) else { return }
        let ext = format == .jpeg ? "jpg" : "png"
        let out = URL.temporaryDirectory.appending(path: "\(document.title).\(ext)")
        try? data.write(to: out)
        shareItem = ShareItem(url: out)
    }

    private func runEncrypt() {
        guard !password.isEmpty,
              let data = ProDocumentActions(files: files).encrypted(document, password: password) else { return }
        let out = URL.temporaryDirectory.appending(path: "\(document.title) (locked).pdf")
        try? data.write(to: out)
        password = ""
        shareItem = ShareItem(url: out)
    }
}

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

private struct PDFKitView: UIViewRepresentable {
    let url: URL
    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.backgroundColor = .clear
        view.document = PDFDocument(url: url)
        return view
    }
    func updateUIView(_ view: PDFView, context: Context) {
        if view.document == nil { view.document = PDFDocument(url: url) }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
