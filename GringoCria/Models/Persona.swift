//
//  Persona.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import Foundation

// MARK: - Persona

struct Persona: Identifiable, Codable {
    let id: UUID
    let subscenarioId: UUID
    let nameEN: String
    let namePT: String
    let systemPrompt: String   // Instruções em português para o personagem
    let openingLine: String    // Primeira frase do vendedor (PT)
    let openingLineEN: String  // Tradução em inglês da primeira frase
    let vendorIcon: String?    // Nome do asset de ícone do vendedor (ex: "IconeMatte")
}
