//
//  TypingIndicatorView.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// MARK: - TypingIndicatorView

/// Indicador de digitação do vendedor/personagem reutilizável entre ScenarioView e AIChatView.
struct TypingIndicatorView: View {
    let vendorIconName: String?
    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ChatVendorAvatarView(iconName: vendorIconName)

            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                        .offset(y: animating ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.4)
                                .repeatForever()
                                .delay(Double(index) * 0.13),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(ChatStyling.vendorBubbleColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.10), radius: 4, y: 2)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { animating = true }
    }
}
