//
//  ScenarioListView.swift
//  GringoCria
//
//  Created by Codex on 15/05/26.
//

import SwiftUI

// MARK: - ScenarioListView

@available(iOS 26, *)
struct ScenarioListView: View {
    enum DisplayMode: Equatable {
        case scenarios
        case premium
    }

    let scenarios: [Scenario]
    let mode: DisplayMode
    let onPremiumTap: (Subscenario) -> Void

    private var visibleSections: [ScenarioListSection] {
        scenarios.compactMap { scenario in
            let subscenarios = filteredSubscenarios(for: scenario)
            guard mode == .scenarios || !subscenarios.isEmpty else { return nil }

            return ScenarioListSection(
                scenario: scenario,
                subscenarios: subscenarios
            )
        }
    }

    var body: some View {
        if visibleSections.isEmpty && mode == .premium {
            premiumEmptyState
        } else {
            scenarioList
        }
    }

    // MARK: - Private

    private var scenarioList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24) {
                ForEach(visibleSections) { section in
                    ScenarioSection(
                        scenario: section.scenario,
                        subscenarios: section.subscenarios,
                        mode: mode,
                        onPremiumTap: onPremiumTap
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    private var premiumEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.sparkles")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)

            Text("No premium conversations yet.")
                .font(.headline)

            Text("Premium AI chats will appear here when they are available.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func filteredSubscenarios(for scenario: Scenario) -> [Subscenario] {
        switch mode {
        case .scenarios:
            scenario.subscenarios.filter { !$0.isLocked }
        case .premium:
            scenario.subscenarios.filter(isPremiumConversation)
        }
    }

    private func isPremiumConversation(_ subscenario: Subscenario) -> Bool {
        subscenario.isLocked && subscenario.scriptName.isEmpty
    }
}

// MARK: - ScenarioListSection

private struct ScenarioListSection: Identifiable {
    let scenario: Scenario
    let subscenarios: [Subscenario]

    var id: UUID {
        scenario.id
    }
}

// MARK: - ScenarioSection

@available(iOS 26, *)
private struct ScenarioSection: View {
    let scenario: Scenario
    let subscenarios: [Subscenario]
    let mode: ScenarioListView.DisplayMode
    let onPremiumTap: (Subscenario) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader

            ForEach(subscenarios) { subscenario in
                subscenarioLink(for: subscenario)
            }
        }
    }

    // MARK: - Private

    private var sectionHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: scenario.icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(scenario.titleEN)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(scenario.titlePT)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private func subscenarioLink(for subscenario: Subscenario) -> some View {
        if shouldOpenPremiumSheet(subscenario) {
            Button {
                onPremiumTap(subscenario)
            } label: {
                SubscenarioCard(subscenario: subscenario)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: subscenario) {
                SubscenarioCard(subscenario: subscenario)
            }
            .buttonStyle(.plain)
        }
    }

    private func shouldOpenPremiumSheet(_ subscenario: Subscenario) -> Bool {
        switch mode {
        case .scenarios:
            subscenario.isLocked
        case .premium:
            true
        }
    }
}

// MARK: - SubscenarioCard

@available(iOS 26, *)
private struct SubscenarioCard: View {
    let subscenario: Subscenario
    @Environment(ProgressService.self) private var progressService

    private var isCompleted: Bool {
        progressService.isCompleted(id: subscenario.id)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subscenario.titleEN)
                    .font(.headline)
                Text(subscenario.titlePT)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            statusIcon
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Private

    @ViewBuilder
    private var statusIcon: some View {
        if subscenario.isLocked {
            let isAIEnabled = subscenario.scriptName.isEmpty
            Image(systemName: isAIEnabled ? "wand.and.sparkles" : "lock.fill")
                .foregroundStyle(isAIEnabled ? .blue : .secondary)
                .font(.title3)
        } else if isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
        }
    }
}

#Preview {
    if #available(iOS 26, *) {
        NavigationStack {
            ScenarioListView(
                scenarios: [
                    Scenario(
                        id: UUID(),
                        titlePT: "Praia",
                        titleEN: "Beach",
                        icon: "beach.umbrella",
                        subscenarios: [
                            Subscenario(
                                id: UUID(),
                                titlePT: "Matte",
                                titleEN: "Mate drink",
                                scriptName: "matte",
                                isLocked: false
                            ),
                            Subscenario(
                                id: UUID(),
                                titlePT: "Matte com IA",
                                titleEN: "AI Mate Chat",
                                scriptName: "",
                                isLocked: true
                            )
                        ]
                    )
                ],
                mode: .scenarios,
                onPremiumTap: { _ in }
            )
        }
        .environment(ProgressService())
    }
}
