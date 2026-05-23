//
//  PremiumGateView.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import SwiftUI
import StoreKit

// MARK: - PremiumGateView

struct PremiumGateView: View {
    @Environment(PremiumService.self) private var premiumService
    @Environment(AIAvailabilityService.self) private var aiAvailabilityService
    @Environment(\.dismiss) private var dismiss

    @State private var purchaseError: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "brain")
                    .font(.system(size: 56))
                    .foregroundStyle(.blue)
                    .padding(.top, 48)

                Text("AI Carioca Chat")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Chat with real Carioca characters powered by Apple Intelligence")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            // Feature list
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "message.badge.waveform",
                    title: "Free conversation",
                    description: "Practice Portuguese in realistic Rio de Janeiro scenarios"
                )
                FeatureRow(
                    icon: "checkmark.seal",
                    title: "Instant feedback",
                    description: "Get grammar and context scores after each message"
                )
                FeatureRow(
                    icon: "person.wave.2",
                    title: "Authentic characters",
                    description: "Talk to Carioca vendors, locals, and more"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            // Availability status
            availabilityNote
                .padding(.horizontal, 24)
                .padding(.bottom, 12)

            // Error banner
            if let error = purchaseError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            // Action buttons
            VStack(spacing: 12) {
                buyButton
                restoreButton
                dismissButton
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Availability Note

    @ViewBuilder
    private var availabilityNote: some View {
        switch aiAvailabilityService.state {
        case .deviceNotEligible:
            Label(
                "Requires iPhone 15 Pro or newer with Apple Intelligence enabled",
                systemImage: "exclamationmark.triangle"
            )
            .font(.caption)
            .foregroundStyle(.orange)
            .multilineTextAlignment(.center)

        case .appleIntelligenceNotEnabled:
            Label(
                "Enable Apple Intelligence in Settings > Apple Intelligence & Siri",
                systemImage: "exclamationmark.triangle"
            )
            .font(.caption)
            .foregroundStyle(.orange)
            .multilineTextAlignment(.center)

        case .modelNotReady:
            Label(
                "Apple Intelligence model is downloading. Please try again later.",
                systemImage: "arrow.down.circle"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

        case .available, .checking, .unknown:
            Label(
                "Requires iPhone 15 Pro or newer with Apple Intelligence enabled",
                systemImage: "iphone"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
    }

    // MARK: - Buttons

    @ViewBuilder
    private var buyButton: some View {
        let isDeviceEligible: Bool = {
            if case .deviceNotEligible = aiAvailabilityService.state { return false }
            return true
        }()

        Button {
            Task { await doPurchase() }
        } label: {
            Group {
                if premiumService.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else if let product = premiumService.product {
                    Text("Unlock for \(product.displayPrice)")
                        .fontWeight(.semibold)
                } else {
                    Text("Unlock Premium")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
        .buttonStyle(.borderedProminent)
        .disabled(premiumService.isLoading || !isDeviceEligible)
    }

    private var restoreButton: some View {
        Button("Restore Purchase") {
            Task { await premiumService.restore() }
        }
        .font(.subheadline)
        .foregroundStyle(.blue)
        .disabled(premiumService.isLoading)
    }

    private var dismissButton: some View {
        Button("Maybe Later") {
            dismiss()
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }

    // MARK: - Actions

    private func doPurchase() async {
        purchaseError = nil
        do {
            try await premiumService.purchase()
        } catch {
            purchaseError = error.localizedDescription
        }
    }
}

// MARK: - FeatureRow

private struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
