//
//  ChatMessage.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import Foundation

// MARK: - ChatRole

enum ChatRole {
    case user
    case vendor
}

// MARK: - ChatMessage

struct ChatMessage: Identifiable {
    let id: UUID
    let role: ChatRole
    let text: String
    var feedback: MessageFeedback?
    var translationEN: String?

    init(id: UUID = UUID(), role: ChatRole, text: String, feedback: MessageFeedback? = nil, translationEN: String? = nil) {
        self.id = id
        self.role = role
        self.text = text
        self.feedback = feedback
        self.translationEN = translationEN
    }
}
