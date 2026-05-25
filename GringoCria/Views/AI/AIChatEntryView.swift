//
//  AIChatEntryView.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import SwiftUI

// MARK: - AIChatEntryView

/// Ponto de entrada para o chat AI: verifica persona, status premium e disponibilidade
/// do Apple Intelligence antes de mostrar a view correta.
struct AIChatEntryView: View {
    let subscenario: Subscenario

    @Environment(AIPersonaService.self) private var aiPersonaService
    @Environment(AIAvailabilityService.self) private var aiAvailabilityService
    // PremiumService permanece injetado para reativar o paywall facilmente quando
    // a compra premium for implementada. Por enquanto, o gate está desativado.
    @Environment(PremiumService.self) private var premiumService

    @State private var viewModel = AIChatEntryViewModel()

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let persona = viewModel.persona {
                // Premium gate temporariamente desativado — sem fluxo de compra ainda.
                // Para reativar: trocar por `if premiumService.isPremium { ... } else { PremiumGateView() }`
                AIChatView(
                    persona: persona,
                    aiPersonaService: aiPersonaService,
                    aiAvailabilityService: aiAvailabilityService
                )
            } else {
                comingSoonView
            }
        }
        .task { await viewModel.resolve(subscenario: subscenario) }
    }

    // MARK: - Coming Soon

    private var comingSoonView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Coming Soon")
                .font(.title2)
                .fontWeight(.bold)

            Text("An AI character for this scenario is in the works. Check back later!")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle(subscenario.titleEN)
        .navigationBarTitleDisplayMode(.inline)
    }
}
