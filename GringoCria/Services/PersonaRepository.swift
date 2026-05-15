//
//  PersonaRepository.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import Foundation

// MARK: - PersonaRepository

/// Carrega personas.json do bundle e oferece lookup por subscenarioId.
/// Struct sem estado — instancie onde precisar sem injeção de dependência.
struct PersonaRepository {
    private let personas: [Persona]

    init() {
        guard let url = Bundle.main.url(forResource: "personas", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([Persona].self, from: data)
        else {
            personas = []
            return
        }
        personas = decoded
    }

    // MARK: - Public

    func persona(for subscenario: Subscenario) -> Persona? {
        personas.first { $0.subscenarioId == subscenario.id }
    }
}
