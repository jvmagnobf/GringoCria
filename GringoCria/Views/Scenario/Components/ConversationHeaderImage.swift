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
        Image(imageName)
            .resizable()
            .scaledToFill()
            .frame(height: 260)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.black, lineWidth: 2))
            
    }
}
