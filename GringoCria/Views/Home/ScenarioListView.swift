//
//  ScenarioListView.swift
//  GringoCria
//
//  Created by Codex on 15/05/26.
//

import SwiftUI

// MARK: - ScenarioListView

struct ScenarioListView: View {
    let scenarios: [Scenario]
    let onSubscenarioTap: (Subscenario) -> Void

    @State private var expandedSections: Set<UUID> = []

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(scenarios) { scenario in
                    ScenarioSection(
                        scenario: scenario,
                        isExpanded: expandedSections.contains(scenario.id),
                        onToggle: { toggleSection(scenario.id) },
                        onSubscenarioTap: onSubscenarioTap
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Private

    private func toggleSection(_ id: UUID) {
        if expandedSections.contains(id) {
            expandedSections.remove(id)
        } else {
            expandedSections.insert(id)
        }
    }
}

// MARK: - ScenarioSection

private struct ScenarioSection: View {
    let scenario: Scenario
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSubscenarioTap: (Subscenario) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader

            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(scenario.subscenarios) { subscenario in
                        SubscenarioCardContainer(
                            subscenario: subscenario,
                            onTap: onSubscenarioTap
                        )
                    }
                }
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Private

    private var sectionHeader: some View {
        Button(action: onToggle) {
            HStack(spacing: 8) {
                Image(systemName: scenario.icon)
                    .font(.title2)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text(scenario.titleEN)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text(scenario.titlePT)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SubscenarioCardContainer

/// Resolve `isUnlocked` consultando o ProgressService do ambiente e
/// delega a ação de tap para o pai (HomeView), que decide se navega ou mostra alert.
private struct SubscenarioCardContainer: View {
    let subscenario: Subscenario
    let onTap: (Subscenario) -> Void

    @Environment(ProgressService.self) private var progressService

    private var isUnlocked: Bool {
        subscenario.isUnlocked(progressService: progressService)
    }

    var body: some View {
        Button {
            onTap(subscenario)
        } label: {
            SubscenarioCard(subscenario: subscenario, isUnlocked: isUnlocked)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SubscenarioCard

private struct SubscenarioCard: View {
    let subscenario: Subscenario
    let isUnlocked: Bool

    @Environment(ProgressService.self) private var progressService

    private var isCompleted: Bool {
        progressService.isCompleted(id: subscenario.id)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(subscenario.titleEN)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(subscenario.titlePT)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            statusIcon
        }
        .padding(16)
        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
        .contentShape(RoundedRectangle(cornerRadius: 12))
        .opacity(isUnlocked ? 1.0 : 0.5)
    }

    // MARK: - Private

    @ViewBuilder
    private var statusIcon: some View {
        if !isUnlocked {
            // Bloqueado por tutorial — cadeado cinza
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)
                .font(.title3)
        } else if subscenario.isAIPremium {
            // Chat AI premium desbloqueado — sparkles azul
            Image(systemName: "wand.and.sparkles")
                .foregroundStyle(.blue)
                .font(.title3)
        } else if isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
        }
    }
}

#Preview {
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
                            titlePT: "Ambulantes",
                            titleEN: "Street Vendors",
                            scriptName: "",
                            isLocked: false,
                            introPages: nil,
                            introPagesEN: nil,
                            vendorIcon: nil,
                            disclaimer: "Start here!",
                            requiresCompletionOf: nil
                        ),
                        Subscenario(
                            id: UUID(),
                            titlePT: "Matte",
                            titleEN: "Mate drink",
                            scriptName: "matte",
                            isLocked: false,
                            introPages: nil,
                            introPagesEN: nil,
                            vendorIcon: nil,
                            disclaimer: nil,
                            requiresCompletionOf: UUID()
                        ),
                        Subscenario(
                            id: UUID(),
                            titlePT: "Matte com IA",
                            titleEN: "AI Mate Chat",
                            scriptName: "",
                            isLocked: true,
                            introPages: nil,
                            introPagesEN: nil,
                            vendorIcon: nil,
                            disclaimer: nil,
                            requiresCompletionOf: UUID()
                        )
                    ]
                )
            ],
            onSubscenarioTap: { _ in }
        )
    }
    .environment(ProgressService())
}
