//
//  PremiumService.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import Foundation
import Observation
import StoreKit

// MARK: - PremiumService

@Observable
@MainActor
final class PremiumService {
    let productId = "com.gringocria.premium.ai"

    private(set) var isPremium: Bool = false
    private(set) var isLoading: Bool = false
    private(set) var product: Product?

    init() {
        Task {
            await checkEntitlements()
            await loadProduct()
        }
    }

    // MARK: - Public

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
        } catch {
            print("[PremiumService] Erro ao carregar produto: \(error)")
        }
    }

    func purchase() async throws {
        guard let product else {
            print("[PremiumService] Produto não disponível para compra.")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isPremium = true
                await transaction.finish()

            case .userCancelled:
                // Cancelamento pelo usuário não é erro — ignora silenciosamente
                break

            case .pending:
                // Compra pendente (ex: aprovação de compras familiares)
                print("[PremiumService] Compra pendente de aprovação.")

            @unknown default:
                break
            }
        } catch {
            // userCancelled is already handled as a .userCancelled result case above
            throw error
        }
    }

    func restore() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            print("[PremiumService] Erro ao restaurar compras: \(error)")
        }
    }

    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productId {
                isPremium = true
                return
            }
        }
    }

    // MARK: - Private

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PremiumError.failedVerification
        case .verified(let value):
            return value
        }
    }
}

// MARK: - PremiumError

enum PremiumError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed. Please try again."
        }
    }
}
