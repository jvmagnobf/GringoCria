 //
//  OnboardingView.swift
//  GringoCria
//
//  Created by João Victor Magno on 21/05/26.
//

import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0

    private struct Page {
        let title: String
        let body: String
        let cristoImage: String
    }

    private let pages: [Page] = [
        Page(
            title: "Welcome to GringoCria",
            body: "Learn the Portuguese cariocas actually speak — not textbook phrases, but the real words you'll need at the beach, on the street, and when things get interesting.",
            cristoImage: "CristoPose"
        ),
        Page(
            title: "Real Conversations",
            body: "Pick a scenario, choose what to say, and see how it plays out. Each conversation branches based on your choices — just like real life. Want to go off-script? The AI Premium chat lets you talk freely, no fixed answers.",
            cristoImage: "CristoPoseChat"
        ),
        Page(
            title: "Know the City",
            body: "The Rio Tips tab has what locals know and tourists find out the hard way — beach prices, how Pix works, what to watch out for, and the numbers to call if things go wrong.",
            cristoImage: "CristoPoseInfo"
        ),
        Page(
            title: "You're Ready",
            body: "The vendors won't slow down for you. But at least now you'll know what to say back. Good luck out there.",
            cristoImage: "CristoPose2 (1)"
        )
    ]

    var body: some View {
        ZStack {
            // Background
            Image("FundoChatRio")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Content layout
            VStack(spacing: 0) {
                // Text card — upper area
                textCard
                    .padding(.horizontal, 24)
                    .padding(.top, 64)

                Spacer()

                // Cristo — bigger, centered
                Image(pages[currentPage].cristoImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 400)
                    .frame(maxWidth: .infinity)
                    .id(currentPage)
                    .transition(.opacity)

                // Page dots below Cristo
                pageDots
                    .padding(.top, 12)
                    .padding(.bottom, 48)
            }
        }
        .onTapGesture {
            if currentPage < pages.count - 1 {
                withAnimation(.easeInOut(duration: 0.35)) {
                    currentPage += 1
                }
            } else {
                onComplete()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: currentPage)
    }

    // MARK: - Subviews

    private var textCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(pages[currentPage].title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(pages[currentPage].body)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        }
        .id(currentPage)
        .transition(.opacity)
    }

    private var pageDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
    }


}

#Preview {
    OnboardingView { }
}
