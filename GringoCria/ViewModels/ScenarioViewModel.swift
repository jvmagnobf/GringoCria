//
//  ScenarioViewModel.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//
//  IMPORTANTE: Certifique-se de que matte.json está adicionado como
//  resource do target GringoCria em Xcode → Build Phases → Copy Bundle Resources.
//  Com PBXFileSystemSynchronizedRootGroup (Xcode 16+) isso ocorre automaticamente.

import Foundation
import UIKit

@Observable
@MainActor
final class ScenarioViewModel {
    private(set) var steps: [ScriptStep]         = []
    private(set) var revealedSteps: [ScriptStep] = []
    private(set) var currentIndex: Int           = 0
    private(set) var isTyping: Bool              = false
    private(set) var isCompleted: Bool           = false
    private(set) var userProfileImage: UIImage?

    private var stepMap: [UUID: ScriptStep] = [:]
    private(set) var currentStepId: UUID?
    private let profileService: ProfileService
    private let progressService: ProgressService
    private var subscenarioId: UUID?

    init(
        profileService: ProfileService = ProfileService(),
        progressService: ProgressService
    ) {
        self.profileService = profileService
        self.progressService = progressService
    }

    // MARK: - Computed

    private var currentStep: ScriptStep? {
        guard let id = currentStepId else { return nil }
        return stepMap[id]
    }

    // MARK: - Public

    func loadUserPhoto() async {
        userProfileImage = await profileService.loadProfilePhoto()
    }

    var currentChoices: [ChoiceOption]? {
        guard !isTyping,
              let step = currentStep,
              step.type == .choice
        else { return nil }
        return step.choices
    }

    func start(scriptName: String, subscenarioId: UUID) async {
        self.subscenarioId = subscenarioId
        await loadScript(named: scriptName)
        guard !steps.isEmpty else { return }
        await revealNextVendorMessage()
    }

    func selectChoice(_ choice: ChoiceOption) {
        // TODO: definir lógica de penalidade para escolhas incorretas
        guard let step = currentStep, step.type == .choice else { return }

        // Exibe a escolha do cliente com o texto selecionado.
        // Usa um UUID novo para não duplicar o id do passo original:
        // ForEach exige IDs únicos em toda a coleção — reutilizar step.id
        // causaria crash com "Fatal error: Duplicate ID" em debug ou
        // comportamento visual incorreto em release.
        if !choice.skipReveal {
            let choiceRevealed = ScriptStep(
                id: UUID(),
                speaker: step.speaker,
                textPT: choice.textPT,
                translationEN: choice.translationEN,
                type: step.type,
                choices: nil,
                vendorVariations: nil,
                vendorVariationsEN: nil,
                isTerminal: false,
                nextStepId: nil
            )
            revealedSteps.append(choiceRevealed)
        }

        if let nextId = choice.nextStepId, stepMap[nextId] != nil {
            currentStepId = nextId
        } else {
            // Avança para o próximo step na sequência original
            if let currentId = currentStepId,
               let currentIdx = steps.firstIndex(where: { $0.id == currentId }),
               currentIdx + 1 < steps.count {
                currentStepId = steps[currentIdx + 1].id
            } else {
                currentStepId = nil
            }
        }
        currentIndex = steps.firstIndex(where: { $0.id == currentStepId }) ?? steps.count

        Task {
            await revealNextVendorMessage()
        }
    }

    // MARK: - Private

    private func loadScript(named name: String) async {
        // Scripts ficam em Resources/scripts/ — o nome do recurso é apenas o
        // nome do arquivo sem extensão (ex: "matte"), não o caminho completo.
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            print("[ScenarioViewModel] \(name).json não encontrado no bundle.")
            return
        }

        do {
            // Mesmo motivo que HomeViewModel.load(): evita bloquear o MainActor
            // com I/O síncrono.
            let data = try await Task.detached(priority: .utility) {
                try Data(contentsOf: url)
            }.value
            steps = try JSONDecoder().decode([ScriptStep].self, from: data)
            stepMap = Dictionary(uniqueKeysWithValues: steps.map { ($0.id, $0) })
            currentStepId = steps.first?.id
            currentIndex = 0
        } catch {
            print("[ScenarioViewModel] Erro ao decodificar \(name).json: \(error)")
            steps = []
        }
    }

    private func revealNextVendorMessage() async {
        do {
            while currentIndex < steps.count {
                let step = steps[currentIndex]
                switch step.type {
                case .vendorVariation:
                    try await processVendorVariation(step)
                case .auto:
                    try await processAutoStep(step)
                case .message where step.speaker == .vendor:
                    try await processVendorMessage(step)
                default:
                    return
                }
                if isCompleted { return }
            }

            // Fallback pós-loop: array esgotado sem step terminal
            if currentIndex >= steps.count {
                isCompleted = true
                if let id = subscenarioId {
                    progressService.markCompleted(id: id)
                }
            }
        } catch is CancellationError {
            isTyping = false
        } catch {
            // Erro inesperado nos métodos de processamento — loga e encerra o loop silenciosamente
            print("[ScenarioViewModel] Erro inesperado em revealNextVendorMessage: \(error)")
            isTyping = false
        }
    }

    // MARK: - Avança currentStepId para o próximo step na sequência

    private func advanceCurrentStep(from step: ScriptStep) {
        // Usa nextStepId do step quando presente; caso contrário avança linearmente
        if let nextId = step.nextStepId, stepMap[nextId] != nil {
            currentStepId = nextId
        } else if let idx = steps.firstIndex(where: { $0.id == step.id }) {
            currentStepId = (idx + 1 < steps.count) ? steps[idx + 1].id : nil
        } else {
            currentStepId = nil
        }
        currentIndex = steps.firstIndex(where: { $0.id == currentStepId }) ?? steps.count
    }

    // MARK: vendorVariation — sorteia uma variação ou silencia o vendedor
    private func processVendorVariation(_ step: ScriptStep) async throws {
        guard let variations = step.vendorVariations, !variations.isEmpty else {
            advanceCurrentStep(from: step)
            return
        }
        let pickedIndex = Int.random(in: 0..<variations.count)
        let picked = variations[pickedIndex]

        if !picked.isEmpty {
            let pickedEN = step.vendorVariationsEN?.indices.contains(pickedIndex) == true
                ? step.vendorVariationsEN![pickedIndex]
                : ""

            isTyping = true
            try await Task.sleep(for: .seconds(1.2))
            isTyping = false

            let ephemeral = ScriptStep(
                id: UUID(),
                speaker: step.speaker,
                textPT: picked,
                translationEN: pickedEN,
                type: step.type,
                choices: nil,
                vendorVariations: nil,
                vendorVariationsEN: nil,
                isTerminal: false,
                nextStepId: nil
            )
            revealedSteps.append(ephemeral)
            // ephemeral.isTerminal é sempre false — sem encerramento aqui
        }
        // picked == "": silêncio do vendedor — sem balão, apenas avança
        advanceCurrentStep(from: step)
    }

    // MARK: auto — exibe a ação do customer e verifica terminal
    private func processAutoStep(_ step: ScriptStep) async throws {
        try await processStepWithTyping(step)
    }

    // MARK: message do vendor — exibe e verifica terminal
    private func processVendorMessage(_ step: ScriptStep) async throws {
        try await processStepWithTyping(step)
    }

    // MARK: helper compartilhado — typing indicator + append + terminal check
    private func processStepWithTyping(_ step: ScriptStep) async throws {
        isTyping = true
        try await Task.sleep(for: .seconds(1.2))
        isTyping = false

        revealedSteps.append(step)
        advanceCurrentStep(from: step)

        if step.isTerminal {
            isCompleted = true
            if let id = subscenarioId { progressService.markCompleted(id: id) }
        }
    }
}
