//
//  AIChatView.swift
//  GringoCria
//
//  Created by João Victor Magno on 15/05/26.
//

import SwiftUI
import UIKit

// MARK: - AIChatView

@available(iOS 26, *)
struct AIChatView: View {
    let persona: Persona

    @Environment(AIPersonaService.self) private var aiPersonaService
    @Environment(AIAvailabilityService.self) private var aiAvailabilityService

    @State private var viewModel: AIChatViewModel
    @State private var inputText: String = ""
    @State private var showTranslation: Bool = false
    @State private var userProfileImage: UIImage?
    @FocusState private var isInputFocused: Bool
    private let profileService = ProfileService()

    init(persona: Persona, aiPersonaService: AIPersonaService, aiAvailabilityService: AIAvailabilityService) {
        self.persona = persona
        _viewModel = State(
            initialValue: AIChatViewModel(
                aiPersonaService: aiPersonaService,
                aiAvailabilityService: aiAvailabilityService
            )
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            messageList
            inputBar
        }
        .background {
            Image("FundoChatRio")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .navigationTitle(persona.nameEN)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showTranslation.toggle()
                } label: {
                    Image(systemName: showTranslation ? "globe.badge.chevron.backward" : "globe")
                }
                .accessibilityLabel("Toggle translation")
            }
        }
        .task {
            await viewModel.start(persona: persona)
        }
        .task {
            userProfileImage = await profileService.loadProfilePhoto()
        }
        .onDisappear {
            viewModel.reset()
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(
                            message: message,
                            showTranslation: showTranslation,
                            persona: persona,
                            userProfileImage: userProfileImage
                        )
                            .id(message.id)

                        if message.role == .user, let feedback = message.feedback {
                            FeedbackBubble(feedback: feedback, userText: message.text)
                                .id("\(message.id)-feedback")
                        }
                    }

                    if viewModel.isTyping {
                        AIChatTypingIndicator(persona: persona)
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture { isInputFocused = false }
            .onChange(of: viewModel.messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isTyping) {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        VStack(spacing: 8) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: 12) {
                TextField("Type in Portuguese...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
                    .submitLabel(.send)
                    .onSubmit(sendMessage)
                    .focused($isInputFocused)
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(ChatStyling.inputBackgroundColor)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.10), radius: 4, y: 2)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(canSend ? Color.blue.opacity(0.95) : Color(.systemGray2))
                        .frame(width: 46, height: 46)
                        .background(ChatStyling.sendButtonColor.opacity(canSend ? 1 : 0.75))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                }
                .disabled(!canSend)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .padding(.bottom, 8)
    }

    // MARK: - Helpers

    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isTyping
    }

    private func sendMessage() {
        let text = inputText
        inputText = ""
        Task {
            await viewModel.send(text, persona: persona)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.25)) {
            if viewModel.isTyping {
                proxy.scrollTo("typing", anchor: .bottom)
            } else if let last = viewModel.messages.last {
                proxy.scrollTo(last.id, anchor: .bottom)
            }
        }
    }
}

// MARK: - ChatBubble

@available(iOS 26, *)
private struct ChatBubble: View {
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

// MARK: - AIChatTypingIndicator

@available(iOS 26, *)
private struct AIChatTypingIndicator: View {
    let persona: Persona
    @State private var animating = false

    private var vendorIconName: String? { ChatStyling.vendorIconName(for: persona) }

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
