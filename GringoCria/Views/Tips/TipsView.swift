//
//  TipsView.swift
//  GringoCria
//
//  Created by João Victor Magno on 20/05/26.
//

import SwiftUI

// MARK: - TipsView

@available(iOS 26, *)
struct TipsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Everything you wish someone had told you before landing.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.65))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                LazyVStack(spacing: 12) {
                    ForEach(Tip.all) { tip in
                        TipCard(tip: tip)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
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
    }
}

// MARK: - Tip

private struct Tip: Identifiable {
    let id: String
    let emoji: String
    let title: String
    let body: String

    static let all: [Tip] = [
        Tip(
            id: "paying",
            emoji: "💸",
            title: "Paying for Things",
            body: "Cash (reais), card, and Pix all work. Pix is Brazil's instant transfer system — faster than Venmo and used by everyone. Carry some cash for beach vendors and street food; not all of them take card."
        ),
        Tip(
            id: "prices",
            emoji: "🏖️",
            title: "Beach Prices",
            body: "Chair or sunshade: R$10–20 each. Mate: R$5–10 (ask to taste before buying). Caipirinha: R$10–25 depending on where you are. If someone quotes you way above these, negotiate — it almost always works."
        ),
        Tip(
            id: "gringo",
            emoji: "⚠️",
            title: "\"Pra Gringo É Mais Caro\"",
            body: "There's a saying in Rio: for foreigners, it costs more. Always ask the price before sitting down, touching anything, or ordering. Negotiating is completely normal — don't skip it."
        ),
        Tip(
            id: "stuff",
            emoji: "👜",
            title: "Keep Your Stuff Close",
            body: "Don't leave your bag, phone, or towel unattended on the beach or anywhere public. When you go in the water, ask someone nearby to watch your things. One second of distraction is enough."
        ),
        Tip(
            id: "phone",
            emoji: "📱",
            title: "Your Phone",
            body: "Don't walk around with your phone in your hand. Don't check it while standing on the street or in a crowd. If you need to look something up, step inside a store or restaurant first."
        ),
        Tip(
            id: "navigation",
            emoji: "🗺️",
            title: "Getting Around",
            body: "Check your route before you leave, not while walking. Download offline maps — some areas have spotty signal. If a street feels off, trust it and turn back. Rio's contrasts can be sharp."
        ),
        Tip(
            id: "card",
            emoji: "💳",
            title: "Card Safety",
            body: "Never let your card leave your hand. Use tap-to-pay when possible. Cover the keypad when entering your PIN. Card cloning happens — check your bank app daily. Only use ATMs inside bank branches."
        ),
        Tip(
            id: "sun",
            emoji: "☀️",
            title: "Sun & Heat",
            body: "Rio's UV index is extreme year-round. Reapply sunscreen every 2 hours and avoid the beach between 10am and 4pm if you burn easily. Stay hydrated — the heat, salt water, and alcohol combination hits harder than you expect."
        ),
        Tip(
            id: "emergency",
            emoji: "🆘",
            title: "Emergency Numbers",
            body: "190 — Police (Polícia Militar)\n192 — Ambulance (SAMU)\n193 — Fire Department\n\nIf you need police as a tourist, ask specifically for the Delegacia do Turista — they speak English and are used to dealing with foreigners."
        ),
        Tip(
            id: "blendin",
            emoji: "🌀",
            title: "Blend In",
            body: "Leave expensive jewelry, watches, and designer bags at the hotel. Dress simply — locals do too. Don't trust vendors blindly: ask the price, negotiate, and verify before paying."
        )
    ]
}

// MARK: - TipCard

@available(iOS 26, *)
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
    if #available(iOS 26, *) {
        NavigationStack {
            TipsView()
        }
    }
}
