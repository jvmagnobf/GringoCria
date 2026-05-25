//
//  PronunciationPhrase.swift
//  GringoCria
//
//  Created by GringoCria on 25/05/26.
//

import Foundation

// MARK: - PronunciationPhrase

struct PronunciationPhrase: Codable, Identifiable {
    let id: String
    let phrasePT: String
    let translationEN: String
    let difficultyHint: String
}
