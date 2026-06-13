import Foundation
import StoreKit
import Observation

/// StoreKit 2 entitlement manager for the single non-consumable Pro unlock.
/// `isPro` is recomputed from `Transaction.currentEntitlements` (the source of
/// truth) — never persisted to disk — so it self-heals on refund/restore and
/// persists across reinstalls/devices.
@MainActor
@Observable
final class IAPManager {
    static let productID = "de.levinschwab.scanlite.pro.lifetime"

    private(set) var isPro = false
    private(set) var product: Product?
    private(set) var purchaseInFlight = false

    init() {
        // App-lifetime listener for out-of-band transactions (Ask-to-Buy, refunds,
        // family sharing). Unstructured task; not stored — it lives with the app.
        _ = listenForTransactions()
    }

    /// Load the product and derive entitlement. Call at launch.
    func start() async {
        await loadProduct()
        await refreshEntitlements()
    }

    func loadProduct() async {
        product = try? await Product.products(for: [Self.productID]).first
    }

    /// Localized display price, with a safe fallback for previews / offline.
    var displayPrice: String {
        product?.displayPrice ?? "€4.99"
    }

    @discardableResult
    func purchase() async throws -> Bool {
        guard let product else { return false }
        purchaseInFlight = true
        defer { purchaseInFlight = false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                await refreshEntitlements()
                return isPro
            }
            return false
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlements()
    }

    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.productID,
               transaction.revocationDate == nil {
                entitled = true
            }
        }
        isPro = entitled
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self?.refreshEntitlements()
                }
            }
        }
    }
}
