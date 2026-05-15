//
//  FeedbackBubble.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import SwiftUI

// MARK: - FeedbackBubble

@available(iOS 26, *)
struct FeedbackBubble: View {
    let feedback: MessageFeedback
    let userText: String

    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            collapsedHeader
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                }

            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 16)
        .padding(.trailing, 48)
    }

    // MARK: - Collapsed Header

    private var collapsedHeader: some View {
        HStack(spacing: 8) {
            ScorePill(score: feedback.contextScore, label: "Context")
            ScorePill(score: feedback.grammarScore, label: "Grammar")

            if feedback.feelsCarioca {
                Text("Feels Carioca!")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
            }

            Spacer()

            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Expanded Content

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()
                .padding(.vertical, 4)

            // Correção da mensagem (só exibe se diferente do original)
            if feedback.correctedMessage != userText {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Corrected:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Text(feedback.correctedMessage)
                        .font(.callout)
                        .foregroundStyle(.orange)
                }
            }

            // Explicação em inglês
            if !feedback.explanationEN.isEmpty {
                Text(feedback.explanationEN)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Alternativas mais naturais
            if !feedback.nicerAlternatives.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You could also say:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    ForEach(feedback.nicerAlternatives, id: \.self) { alternative in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(alternative)
                                .font(.caption)
                                .foregroundStyle(.primary)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - ScorePill

@available(iOS 26, *)
private struct ScorePill: View {
    let score: Int
    let label: String

    private var pillColor: Color {
        switch score {
        case 7...10: return .green
        case 4...6:  return .yellow
        default:     return .red
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text("\(score)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(pillColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(pillColor.opacity(0.12))
        .clipShape(Capsule())
    }
}
