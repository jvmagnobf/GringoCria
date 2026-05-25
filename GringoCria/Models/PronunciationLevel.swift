//
//  PronunciationLevel.swift
//  GringoCria
//
//  Created by GringoCria on 25/05/26.
//

import Foundation

// MARK: - PronunciationLevel

enum PronunciationLevel: String, CaseIterable, Codable {
    case easy   = "easy"
    case medium = "medium"
    case hard   = "hard"

    // MARK: - Computed

    /// Níveis médio e difícil são premium (reservados para versões futuras com paywall).
    var isPremium: Bool { self != .easy }

    var titleEN: String {
        switch self {
        case .easy:   return "Easy"
        case .medium: return "Medium"
        case .hard:   return "Hard"
        }
    }

    var titlePT: String {
        switch self {
        case .easy:   return "Fácil"
        case .medium: return "Médio"
        case .hard:   return "Difícil"
        }
    }

    /// SF Symbol representativo de cada nível.
    var icon: String {
        switch self {
        case .easy:   return "1.circle.fill"
        case .medium: return "2.circle.fill"
        case .hard:   return "3.circle.fill"
        }
    }
}
