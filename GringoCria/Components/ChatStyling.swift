//
//  ChatStyling.swift
//  GringoCria
//
//  Created by Codex on 21/05/26.
//

import Foundation
import SwiftUI

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

    static func headerImageName(for subscenario: Subscenario) -> String? {
        switch subscenario.scriptName {
        case "matte",
             "biscoito-globo": return "MatteFundo"
        case "caipirinha":     return "CaipiFundo"
        case "barraca-praia":  return "BarracaFundo"
        case "esfiha":         return "EsfihaFundo"
        case "menu-quiosque":  return "GarcomFundo"
        case "policial":       return "PolicialFundo2"
        case "salva-vidas":    return "SalvavidasFundo"
        case "delegacia":      return "CriaFundo"
        default:               return nil
        }
    }

    static func vendorIconName(for persona: Persona) -> String? {
        persona.vendorIcon
    }
}
