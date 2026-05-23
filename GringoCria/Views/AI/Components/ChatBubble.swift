//
//  ChatBubble.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI
import UIKit

// MARK: - ChatBubble

/// Componente AI-only: exibe bolhas do chat livre com IA. Para o chat de script, use MessageBubble.
struct ChatBubble: View {
    let message: ChatMessage
    let showTranslation: Bool
    let persona: Persona
    let userProfileImage: UIImage?

    private var isUser: Bool { message.role == .user }
    private var vendorIconName: String? { ChatStyling.vendorIconName(for: persona) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isUser {
                Spacer(minLength: 24)
                bubble
                ChatUserAvatarView(image: userProfileImage)
            } else {
                ChatVendorAvatarView(iconName: vendorIconName)
                bubble
                Spacer(minLength: 24)
            }
        }
        .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
    }

    private var bubble: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
            Text(message.text)
                .font(.body)
                .foregroundStyle(Color("mensagem_fonte"))

            if showTranslation, let translation = message.translationEN, !translation.isEmpty {
                Text(translation)
                    .font(.caption)
                    .foregroundStyle(Color("mensagem_fonte").opacity(0.65))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isUser ? ChatStyling.userBubbleColor : ChatStyling.vendorBubbleColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
    }
}
