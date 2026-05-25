//
//  TipsView.swift
//  GringoCria
//
//  Created by João Victor Magno on 20/05/26.
//

import SwiftUI

// MARK: - TipsView

struct TipsView: View {
    @State private var viewModel = TipsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Things nobody tells you until it's too late.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                if let error = viewModel.loadError {
                    Text(error)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.tips) { tip in
                            TipCard(tip: tip)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .background {
            Image("menu_background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationTitle("Rio Tips")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load() }
    }
}

// MARK: - TipCard

private struct TipCard: View {
    let tip: Tip

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Text(tip.emoji)
                    .font(.title2)

                Text(tip.title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            Text(tip.body)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassEffect(in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        TipsView()
    }
}
