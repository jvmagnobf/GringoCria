//
//  ChatAvatarViews.swift
//  GringoCria
//
//  Created by João Victor Magno on 23/05/26.
//

import SwiftUI
import UIKit

// MARK: - ChatVendorAvatarView

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

// MARK: - ChatUserAvatarView

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
