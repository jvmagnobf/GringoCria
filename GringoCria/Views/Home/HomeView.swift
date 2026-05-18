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
                ScenarioListView(
                    scenarios: viewModel.scenarios,
                    mode: .scenarios,
                    onPremiumTap: { _ in }
                )
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
