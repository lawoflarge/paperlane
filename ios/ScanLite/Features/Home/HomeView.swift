import SwiftUI
import SwiftData

/// Home screen: a giant Scan button (<=1 tap to capture) over a local-first library.
struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Environment(IAPManager.self) private var iap
    @Query(sort: \ScannedDocument.createdAt, order: .reverse) private var documents: [ScannedDocument]

    @State private var showScanner = false
    @State private var selected: ScannedDocument?
    @State private var renaming: ScannedDocument?
    @State private var renameText = ""
    @State private var showMerge = false
    @State private var showPaywall = false

    private let files = DocumentFileStore.defaultStore()
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                PaperTheme.surface.ignoresSafeArea().paperGrain()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        if documents.isEmpty {
                            emptyState
                        } else {
                            library
                        }
                        Color.clear.frame(height: 110)
                    }
                    .padding(20)
                }

                InkScanButton(action: startScan)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showScanner) {
                DocumentScannerView { images in handleScan(images) }
                    .ignoresSafeArea()
            }
            .sheet(item: $selected) { doc in
                DocumentPreviewView(document: doc, files: files)
            }
            .sheet(isPresented: $showMerge) { MergeView() }
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .alert("Rename document", isPresented: renameBinding) {
                TextField("Name", text: $renameText)
                Button("Save") { commitRename() }
                Button("Cancel", role: .cancel) { renaming = nil }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ScanLite")
                    .font(.serif(34, .bold))
                    .foregroundStyle(PaperTheme.inkPrimary)
                Text("\(documents.count) document\(documents.count == 1 ? "" : "s")")
                    .font(.system(size: 13).monospacedDigit())
                    .foregroundStyle(PaperTheme.inkSecondary)
            }
            Spacer()
            if documents.count >= 2 {
                Button { combine() } label: {
                    Label("Combine", systemImage: "doc.on.doc")
                        .font(.system(size: 14, weight: .semibold))
                }
                .tint(PaperTheme.accent)
            }
        }
    }

    private var library: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(documents) { doc in
                Button { selected = doc } label: {
                    PaperCardTile(
                        title: doc.title,
                        pageCount: doc.pageCount,
                        createdAt: doc.createdAt,
                        fileSizeBytes: doc.fileSizeBytes,
                        pdfURL: files.fileURL(doc.fileName)
                    )
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button { startRename(doc) } label: { Label("Rename", systemImage: "pencil") }
                    Button(role: .destructive) { delete(doc) } label: { Label("Delete", systemImage: "trash") }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.viewfinder")
                .font(.system(size: 52, weight: .light))
                .foregroundStyle(PaperTheme.inkTertiary)
            Text("No documents yet")
                .font(.serif(22, .semibold))
                .foregroundStyle(PaperTheme.inkPrimary)
            Text("Tap Scan to turn any page into a clean, searchable PDF.")
                .font(.system(size: 15))
                .foregroundStyle(PaperTheme.inkSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var renameBinding: Binding<Bool> {
        Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })
    }

    // MARK: - Actions

    private func startScan() {
        #if targetEnvironment(simulator)
        handleScan(Samples.pages())
        #else
        showScanner = true
        #endif
    }

    private func handleScan(_ images: [UIImage]) {
        guard !images.isEmpty else { return }
        let data = PDFAssembler().assemble(images: images)
        _ = try? DocumentStore(context: context).save(
            title: Samples.autoName(),
            pdfData: data,
            pageCount: images.count
        )
    }

    private func combine() {
        if iap.isPro { showMerge = true } else { showPaywall = true }
    }

    private func delete(_ doc: ScannedDocument) {
        try? DocumentStore(context: context).delete(doc)
    }

    private func startRename(_ doc: ScannedDocument) {
        renameText = doc.title
        renaming = doc
    }

    private func commitRename() {
        guard let doc = renaming else { return }
        try? DocumentStore(context: context).rename(doc, to: renameText)
        renaming = nil
    }
}
