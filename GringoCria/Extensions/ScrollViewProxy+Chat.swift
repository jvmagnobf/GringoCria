//
//  ScrollViewProxy+Chat.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// MARK: - ScrollViewProxy + Chat helpers

extension ScrollViewProxy {
    /// Faz scroll até o último item da conversa.
    /// - Se `isTyping` for true, ancora em "typing".
    /// - Caso contrário, ancora no `lastId` fornecido.
    func scrollToLatest(isTyping: Bool, lastId: (some Hashable)?) {
        withAnimation(.easeOut(duration: 0.25)) {
            if isTyping {
                scrollTo("typing", anchor: .bottom)
            } else if let lastId {
                scrollTo(lastId, anchor: .bottom)
            }
        }
    }
}
