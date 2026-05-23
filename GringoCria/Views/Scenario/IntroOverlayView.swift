//
//  IntroOverlayView.swift
//  GringoCria

import SwiftUI

struct IntroOverlayView: View {
    let pages: [String]
    let onComplete: () -> Void

    @State private var currentPage = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.78)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text(pages[currentPage])
                    .font(.body)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .id(currentPage)
                    .transition(.opacity)

                Spacer()

                // Page dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.35))
                            .frame(width: 8, height: 8)
                    }
                }

                Text(currentPage < pages.count - 1 ? "Tap to continue" : "Tap to start")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 48)
            }
        }
        .onTapGesture {
            if currentPage < pages.count - 1 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage += 1
                }
            } else {
                onComplete()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pages[currentPage])
        .accessibilityHint(currentPage < pages.count - 1 ? "Double tap to continue" : "Double tap to start the conversation")
        .accessibilityAddTraits(.isButton)
    }
}
