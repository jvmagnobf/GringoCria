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

                Text(currentPage < pages.count - 1 ? "Tap or swipe to continue" : "Tap or swipe to start")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.bottom, 48)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            advance()
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let threshold: CGFloat = 50

                    if horizontal < -threshold {
                        advance()
                    } else if horizontal > threshold {
                        goBack()
                    }
                }
        )
        .animation(.easeInOut(duration: 0.3), value: currentPage)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pages[currentPage])
        .accessibilityHint(currentPage < pages.count - 1 ? "Double tap or swipe left to continue" : "Double tap or swipe left to start the conversation")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Navigation

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            onComplete()
        }
    }

    private func goBack() {
        guard currentPage > 0 else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPage -= 1
        }
    }
}
