//
//  ScriptStep.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation

enum Speaker: String, Codable {
    case vendor
    case customer
}

enum StepType: String, Codable {
    case message
    case choice
    case vendorVariation
    case auto
}

struct ScriptStep: Identifiable, Codable {
    let id: UUID
    let speaker: Speaker
    let textPT: String
    let translationEN: String
    let type: StepType
    let choices: [ChoiceOption]?
    let vendorVariations: [String]?
    let vendorVariationsEN: [String]?
    let isTerminal: Bool
    let nextStepId: UUID?

    // MARK: - Memberwise init (usado em ScenarioViewModel para criar steps efêmeros)

    init(
        id: UUID,
        speaker: Speaker,
        textPT: String,
        translationEN: String,
        type: StepType,
        choices: [ChoiceOption]?,
        vendorVariations: [String]?,
        vendorVariationsEN: [String]?,
        isTerminal: Bool,
        nextStepId: UUID? = nil
    ) {
        self.id = id
        self.speaker = speaker
        self.textPT = textPT
        self.translationEN = translationEN
        self.type = type
        self.choices = choices
        self.vendorVariations = vendorVariations
        self.vendorVariationsEN = vendorVariationsEN
        self.isTerminal = isTerminal
        self.nextStepId = nextStepId
    }

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id, speaker, textPT, translationEN, type, choices
        case vendorVariations, vendorVariationsEN, isTerminal, nextStepId
    }

    init(from decoder: Decoder) throws {
        let container      = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try container.decode(UUID.self, forKey: .id)
        speaker            = try container.decode(Speaker.self, forKey: .speaker)
        textPT             = try container.decode(String.self, forKey: .textPT)
        translationEN      = try container.decode(String.self, forKey: .translationEN)
        type               = try container.decode(StepType.self, forKey: .type)
        choices            = try container.decodeIfPresent([ChoiceOption].self, forKey: .choices)
        vendorVariations   = try container.decodeIfPresent([String].self, forKey: .vendorVariations)
        vendorVariationsEN = try container.decodeIfPresent([String].self, forKey: .vendorVariationsEN)
        isTerminal         = (try? container.decode(Bool.self, forKey: .isTerminal)) ?? false
        nextStepId         = try container.decodeIfPresent(UUID.self, forKey: .nextStepId)
    }
}

struct ChoiceOption: Identifiable, Codable, Hashable {
    let id: UUID
    let textPT: String
    let translationEN: String
    let isCorrect: Bool?
    let nextStepId: UUID?
    let skipReveal: Bool

    // MARK: - Decodable

    enum CodingKeys: String, CodingKey {
        case id, textPT, translationEN, isCorrect, nextStepId, skipReveal
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id            = try container.decode(UUID.self, forKey: .id)
        textPT        = try container.decode(String.self, forKey: .textPT)
        translationEN = try container.decode(String.self, forKey: .translationEN)
        isCorrect     = try container.decodeIfPresent(Bool.self, forKey: .isCorrect)
        nextStepId    = try container.decodeIfPresent(UUID.self, forKey: .nextStepId)
        skipReveal    = (try? container.decode(Bool.self, forKey: .skipReveal)) ?? false
    }
}
