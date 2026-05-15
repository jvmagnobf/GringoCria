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
@available(iOS 26, *)
struct AIChatEntryView: View {
    let subscenario: Subscenario

    @Environment(AIPersonaService.self) private var aiPersonaService
    @Environment(AIAvailabilityService.self) private var aiAvailabilityService

    private let repository = PersonaRepository()

    var body: some View {
        if let persona = repository.persona(for: subscenario) {
            AIChatView(
                persona: persona,
                aiPersonaService: aiPersonaService,
                aiAvailabilityService: aiAvailabilityService
            )
        } else {
            comingSoonView
        }
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
    }
}
