//
//  ConversationHeaderImage.swift
//  GringoCria
//
//  Created by João Victor Magno on 11/05/26.
//

import SwiftUI

// MARK: - ConversationHeaderImage

struct ConversationHeaderImage: View {
    let imageName: String
    let label: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 260)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Label(label.uppercased(), systemImage: "mappin")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .clipShape(Capsule())
                .padding(12)
        }
        .frame(maxWidth: .infinity)
    }
}
