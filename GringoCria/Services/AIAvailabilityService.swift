//
//  AIAvailabilityService.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import Foundation
import Observation
import FoundationModels

// MARK: - AIAvailabilityState

enum AIAvailabilityState {
    case checking
    case available
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case unknown(String)
}

// MARK: - AIAvailabilityService

@Observable
@MainActor
final class AIAvailabilityService {
    private(set) var state: AIAvailabilityState = .checking

    init() {
        check()
    }

    // MARK: - Public

    func check() {
        let availability = SystemLanguageModel.default.availability

        switch availability {
        case .available:
            state = .available
        case .unavailable(.deviceNotEligible):
            state = .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            state = .appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            state = .modelNotReady
        case .unavailable(let reason):
            state = .unknown(String(describing: reason))
        @unknown default:
            state = .unknown("Unknown availability state")
        }
    }
}
