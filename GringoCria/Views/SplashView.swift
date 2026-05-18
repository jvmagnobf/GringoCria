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
            Image("TELA1GRINGOCRIA")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                Spacer()

                Text("Click to continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.bottom, 60)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onContinue()
        }
    }
}

#Preview {
    SplashView(onContinue: {})
}
