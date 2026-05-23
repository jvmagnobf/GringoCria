//
//  SplashView.swift
//  GringoCria
//
//  Created by João Victor Magno on 16/05/26.
//

import SwiftUI

// MARK: - SplashView

struct SplashView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Image("telaWelcome")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("Tap to continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.bottom, 60)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onContinue()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("GringoCria — welcome screen")
        .accessibilityHint("Double tap to enter")
        .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    SplashView(onContinue: {})
}
