//
//  AIChatEntryViewModel.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation
import Observation

// MARK: - AIChatEntryViewModel

@Observable
@MainActor
final class AIChatEntryViewModel {
    private(set) var persona: Persona?
    private(set) var isLoading = true

    // MARK: - Public

    func resolve(subscenario: Subscenario) async {
        let personas = await PersonaRepository.load()
        persona = personas.first { $0.subscenarioId == subscenario.id }
        isLoading = false
    }
}
