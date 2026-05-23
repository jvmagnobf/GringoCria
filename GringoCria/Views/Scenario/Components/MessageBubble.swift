//
//  MessageBubble.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI
import UIKit

// MARK: - MessageBubble

struct MessageBubble: View {
    let step: ScriptStep
    let showTranslation: Bool
    let subscenario: Subscenario
    let userProfileImage: UIImage?

    // Lê do ambiente para que as mudanças em currentSpeakingStepId disparem
    // atualizações de UI — passar como `let` não registra a dependência de
    // observação em @Observable corretamente para sub-views.
    @Environment(SpeechService.self) private var speechService

    private var isVendor: Bool { step.speaker == .vendor }
    private var isSpeakingThis: Bool { speechService.currentSpeakingStepId == step.id }
    private var vendorIconName: String? { ChatStyling.vendorIconName(for: subscenario) }

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isVendor {
                ChatVendorAvatarView(iconName: vendorIconName)
                bubbleRow
                Spacer(minLength: 24)
            } else {
                Spacer(minLength: 24)
                bubbleRow
                ChatUserAvatarView(image: userProfileImage)
            }
        }
        .frame(maxWidth: .infinity, alignment: isVendor ? .leading : .trailing)
    }

    private var bubbleRow: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isVendor {
                bubble
                speakerButton
            } else {
                speakerButton
                bubble
            }
        }
    }

    private var bubble: some View {
        VStack(alignment: isVendor ? .leading : .trailing, spacing: 4) {
            Text(step.textPT)
                .font(.body)
                .foregroundStyle(Color("mensagem_fonte"))

            if showTranslation && !step.translationEN.isEmpty {
                Text(step.translationEN)
                    .font(.caption)
                    .foregroundStyle(Color("mensagem_fonte").opacity(0.65))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isVendor ? ChatStyling.vendorBubbleColor : ChatStyling.userBubbleColor)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.10), radius: 4, y: 2)
    }

    private var speakerButton: some View {
        Button {
            if isSpeakingThis {
                speechService.stop()
            } else {
                speechService.speak(text: step.textPT, stepId: step.id)
            }
        } label: {
            Image(systemName: isSpeakingThis ? "speaker.slash" : "speaker.wave.2")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel(isSpeakingThis ? "Stop pronunciation" : "Play pronunciation")
    }
}
