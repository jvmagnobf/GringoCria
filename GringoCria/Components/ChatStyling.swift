//
//  ChatStyling.swift
//  GringoCria
//
//  Created by Codex on 21/05/26.
//

import Foundation
import SwiftUI
import UIKit

enum ChatStyling {
    static let userBubbleColor = Color("branco_mensagem")
    static let vendorBubbleColor = Color("amarelo_mensagem")
    static let inputBackgroundColor = Color("branco_mensagem")
    static let sendButtonColor = Color("amarelo_mensagem")
    static let userAvatarBackground = Color(red: 0.10, green: 0.47, blue: 0.67)

    static func vendorIconName(for subscenario: Subscenario) -> String? {
        // Ícone explícito definido no scenarios.json tem prioridade
        if let icon = subscenario.vendorIcon { return icon }

        switch subscenario.scriptName {
        case "matte", "biscoito-globo":
            return "IconeMatte"
        case "caipirinha", "menu-quiosque":
            return "IconeCaipi"
        case "esfiha":
            return "IconeEsifiha"
        case "barraca-praia":
            return "IconeCadeira"
        case "policial", "delegacia":
            return "IconePolicia"
        case "salva-vidas":
            return "IconeSalvaVidas"
        default:
            return nil
        }
    }

    static func vendorIconName(for persona: Persona) -> String? {
        switch persona.subscenarioId.uuidString.uppercased() {
        case "A2000001-0000-0000-0000-000000000001", // AI Mate Chat
             "A2000002-0000-0000-0000-000000000002": // AI Globo Biscuit Chat
            return "IconeMatte"
        case "A2000003-0000-0000-0000-000000000003":
            return "IconeCaipi"
        case "A2000004-0000-0000-0000-000000000004":
            return "IconeEsifiha"
        case "A2000005-0000-0000-0000-000000000005":
            return "IconeCadeira"
        default:
            return nil
        }
    }
}

struct ChatVendorAvatarView: View {
    let iconName: String?

    var body: some View {
        Group {
            if let iconName {
                Image(iconName)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .foregroundStyle(.white)
                    .background(Circle().fill(Color(.systemGray3)))
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
        .shadow(color: .black.opacity(0.14), radius: 4, y: 2)
    }
}

struct ChatUserAvatarView: View {
    let image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(ChatStyling.userAvatarBackground)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ChatStyling.userBubbleColor)
                    }
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white.opacity(0.35), lineWidth: 1))
        .shadow(color: .black.opacity(0.14), radius: 4, y: 2)
    }
}
