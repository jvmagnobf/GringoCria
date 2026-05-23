//
//  Scenario.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation

struct Scenario: Identifiable, Codable {
    let id: UUID
    let titlePT: String
    let titleEN: String
    let icon: String
    let subscenarios: [Subscenario]
}

struct Subscenario: Identifiable, Codable, Hashable {
    let id: UUID
    let titlePT: String
    let titleEN: String
    let scriptName: String
    let isLocked: Bool
    let introPages: [String]?
    let introPagesEN: [String]?
    let vendorIcon: String?
    let disclaimer: String?
}

// MARK: - Subscenario Extensions

extension Subscenario {
    /// Retorna as páginas de intro preferidas: inglês quando disponível, senão português.
    var preferredIntroPages: [String]? {
        if let introPagesEN, !introPagesEN.isEmpty { return introPagesEN }
        return introPages
    }

    /// Indica que este subscenário é um chat AI premium (bloqueado, sem script fixo).
    /// Usar esta propriedade em vez de `isLocked && scriptName.isEmpty` diretamente nas views
    /// garante que o único lugar a atualizar ao adicionar novos tipos de conteúdo locked seja o modelo.
    var isAIPremium: Bool {
        isLocked && scriptName.isEmpty
    }
}
