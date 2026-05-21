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
}
