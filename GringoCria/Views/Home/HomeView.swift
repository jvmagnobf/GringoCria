//
//  HomeView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

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
                            ScenarioSection(scenario: scenario)
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
        .task {
            await viewModel.load()
        }
    }
}

// MARK: - ScenarioSection

private struct ScenarioSection: View {
    let scenario: Scenario

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
                    SubscenarioCard(subscenario: subscenario)
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
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
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
    NavigationStack {
        HomeView()
    }
    .environment(AppState())
    .environment(ProgressService())
}
