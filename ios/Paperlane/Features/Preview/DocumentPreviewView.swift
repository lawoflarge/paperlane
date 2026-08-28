import SwiftUI
import SwiftData
import PDFKit
import Contacts

/// Full PDF preview with share + free rotate + Pro actions (OCR, image export, password).
/// Every Pro entry point routes a non-Pro user to the paywall — never a no-op.
struct DocumentPreviewView: View {
    let document: ScannedDocument
    let files: DocumentFileStore
    @Environment(IAPManager.self) private var iap
    @Environment(ConsentManager.self) private var consent
    @Environment(AdGate.self) private var gate
    @Environment(InterstitialAdManager.self) private var interstitial
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showShare = false
    @State private var showPaywall = false
    @State private var working = false
    @State private var reloadToken = UUID()
    @State private var shareItem: ShareItem?
    @State private var askPassword = false
    @State private var password = ""
    @State private var showPages = false
    @State private var showMarkup = false
    @State private var markupImage: UIImage?
    @State private var showContact = false
    @State private var contactToSave: CNContact?
    /// Page the reader is on; markup edits this page, not always the first one.
    @State private var currentPageIndex = 0

    private var url: URL { files.fileURL(document.fileName) }

    var body: some View {
        NavigationStack {
            ZStack {
                PDFKitView(url: url, currentPage: $currentPageIndex)
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
                ToolbarItem(placement: .topBarLeading) { Button("Done") { finishPreview() } }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showShare = true } label: { Image(systemName: "square.and.arrow.up") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { rotate() } label: { Image(systemName: "rotate.right") }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showPages = true } label: { Image(systemName: "square.stack") }
                }
                ToolbarItem(placement: .topBarTrailing) { proMenu }
            }
            .tint(PaperTheme.accent)
            .sheet(isPresented: $showPages, onDismiss: { reloadToken = UUID() }) {
                PageManagerView(document: document, files: files)
            }
            .sheet(isPresented: $showMarkup) {
                if let image = markupImage {
                    MarkupView(pageImage: image) { flattened in applyMarkup(flattened) }
                }
            }
            .sheet(isPresented: $showContact) {
                if let contact = contactToSave {
                    ContactCardView(contact: contact) { showContact = false }.ignoresSafeArea()
                }
            }
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
            Menu {
                Button { gated { copyText() } } label: { Label("Copy text", systemImage: "doc.on.clipboard") }
                Button { gated { exportText(.txt) } } label: { Label("Export .txt", systemImage: "doc.text") }
                Button { gated { exportText(.docx) } } label: { Label("Export .docx (Word)", systemImage: "doc.richtext") }
            } label: { Label("Export text", systemImage: "text.viewfinder") }
            Button { gated { smartRename() } } label: { Label("Smart rename", systemImage: "sparkles") }
            Button { gated { export(.jpeg) } } label: { Label("Export as JPG", systemImage: "photo") }
            Button { gated { export(.png) } } label: { Label("Export as PNG", systemImage: "photo.on.rectangle") }
            Menu {
                ForEach(PDFCompressor.Quality.allCases) { quality in
                    Button { gated { compress(quality) } } label: { Text(quality.label) }
                }
            } label: { Label("Compress PDF", systemImage: "arrow.down.right.and.arrow.up.left") }
            Button { gated { startMarkup() } } label: { Label("Markup & sign", systemImage: "signature") }
            Button { gated { startContact() } } label: { Label("Save as contact", systemImage: "person.crop.circle.badge.plus") }
            Button { gated { askPassword = true } } label: { Label("Password Protect", systemImage: "lock") }
        } label: {
            Image(systemName: "wand.and.stars")
        }
    }

    private enum TextFormat { case txt, docx }

    // MARK: - Dismiss (capped interstitial for free users)

    private func finishPreview() {
        if !iap.isPro && consent.canRequestAds && gate.canShowInterstitial {
            gate.recordInterstitial()
            interstitial.present { dismiss() }
        } else {
            dismiss()
        }
    }

    // MARK: - Pro gate

    private func gated(_ action: () -> Void) {
        if iap.isPro { action() } else { showPaywall = true }
    }

    // MARK: - Free actions

    /// Rotate every page 90° clockwise, persist it, and refresh the preview. Free.
    private func rotate() {
        try? DocumentStore(context: context).rotate(document)
        reloadToken = UUID()
    }

    private func export(_ format: ImageExporter.Format) {
        guard let data = ProDocumentActions(files: files).exportImage(document, format: format) else { return }
        let ext = format == .jpeg ? "jpg" : "png"
        let out = URL.temporaryDirectory.appending(path: "\(document.title).\(ext)")
        try? data.write(to: out)
        shareItem = ShareItem(url: out)
    }

    private func copyText() {
        UIPasteboard.general.string = document.ocrText
    }

    private func exportText(_ format: TextFormat) {
        let exporter = TextDocumentExporter()
        let text = document.ocrText
        let (data, ext): (Data, String) = format == .txt
            ? (exporter.txtData(text), "txt")
            : (exporter.docxData(text), "docx")
        let out = URL.temporaryDirectory.appending(path: "\(document.title).\(ext)")
        try? data.write(to: out)
        shareItem = ShareItem(url: out)
    }

    private func compress(_ quality: PDFCompressor.Quality) {
        guard let data = try? files.read(fileName: document.fileName),
              let compressed = PDFCompressor().compress(data, quality: quality) else { return }
        let out = URL.temporaryDirectory.appending(path: "\(document.title) (compressed).pdf")
        try? compressed.write(to: out)
        shareItem = ShareItem(url: out)
    }

    private func startMarkup() {
        guard let data = try? files.read(fileName: document.fileName),
              let pdf = PDFDocument(data: data),
              let page = pdf.page(at: markupPageIndex(in: pdf)) else { return }
        let bounds = page.bounds(for: .mediaBox)
        markupImage = page.thumbnail(of: bounds.size, for: .mediaBox)
        showMarkup = true
    }

    private func applyMarkup(_ flattened: UIImage) {
        guard let data = try? files.read(fileName: document.fileName),
              let pdf = PDFDocument(data: data), let newPage = PDFPage(image: flattened) else { return }
        let index = markupPageIndex(in: pdf)
        pdf.removePage(at: index)
        pdf.insert(newPage, at: index)
        guard let out = pdf.dataRepresentation() else { return }
        try? DocumentStore(context: context).replace(document, withData: out, pageCount: pdf.pageCount)
        reloadToken = UUID()
    }

    /// The visible page, clamped into the document. Markup used to hard-code page 0,
    /// so annotating any later page silently rasterised and replaced the first one.
    private func markupPageIndex(in pdf: PDFDocument) -> Int {
        min(max(currentPageIndex, 0), max(pdf.pageCount - 1, 0))
    }

    private func startContact() {
        let parsed = BusinessCardParser.parse(ocrText: document.ocrText)
        let contact = CNMutableContact()
        if let name = parsed.fullName {
            let parts = name.split(separator: " ").map(String.init)
            contact.givenName = parts.first ?? name
            if parts.count > 1 { contact.familyName = parts.dropFirst().joined(separator: " ") }
        }
        if let org = parsed.organization { contact.organizationName = org }
        if let email = parsed.email {
            contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: email as NSString)]
        }
        if let phone = parsed.phone {
            contact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: phone))]
        }
        contactToSave = contact
        showContact = true
    }

    private func smartRename() {
        working = true
        Task {
            let name = await SmartNamer.suggest(ocrText: document.ocrText)
            try? DocumentStore(context: context).rename(document, to: name)
            working = false
        }
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
    /// Index of the page the reader is actually looking at, so per-page actions
    /// (markup) act on it instead of always on page one.
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator { Coordinator(currentPage: $currentPage) }

    final class Coordinator: NSObject {
        private let currentPage: Binding<Int>
        init(currentPage: Binding<Int>) { self.currentPage = currentPage }

        @objc func pageChanged(_ note: Notification) {
            guard let view = note.object as? PDFView,
                  let page = view.currentPage,
                  let index = view.document?.index(for: page) else { return }
            currentPage.wrappedValue = index
        }
    }

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.backgroundColor = .clear
        view.document = PDFDocument(url: url)
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: view)
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
