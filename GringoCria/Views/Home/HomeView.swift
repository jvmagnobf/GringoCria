//
//  HomeView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

@available(iOS 26, *)
struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var selectedLockedSubscenario: Subscenario?

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.scenarios.isEmpty {
                if viewModel.loadError != nil {
                    Text("Could not load scenarios. Please restart the app.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    Text("No scenarios available yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(viewModel.scenarios) { scenario in
                            ScenarioSection(
                                scenario: scenario,
                                onLockedTap: { subscenario in
                                    selectedLockedSubscenario = subscenario
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationTitle("GringoCria")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Subscenario.self) { subscenario in
            ScenarioView(subscenario: subscenario)
        }
        .sheet(item: $selectedLockedSubscenario) { subscenario in
            AIChatEntryView(subscenario: subscenario)
        }
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - ScenarioSection

private struct ScenarioSection: View {
    let scenario: Scenario
    let onLockedTap: (Subscenario) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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

            ForEach(scenario.subscenarios) { subscenario in
                if subscenario.isLocked {
                    Button {
                        onLockedTap(subscenario)
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
        }
    }
}

// MARK: - SubscenarioCard

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

            if subscenario.isLocked {
                // Subscenario bloqueado com script vazio → acesso via AI premium
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
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    if #available(iOS 26, *) {
        NavigationStack {
            HomeView()
        }
        .environment(AppState())
        .environment(ProgressService())
        .environment(AIAvailabilityService())
        .environment(AIPersonaService())
        .environment(PremiumService())
    }
}
