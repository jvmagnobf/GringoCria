//
//  AuthenticatedTabView.swift
//  GringoCria
//
//  Created by João Victor Magno on 12/05/26.
//

import SwiftUI

// MARK: - AuthenticatedTabView

struct AuthenticatedTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
        }
    }
}

#Preview {
    AuthenticatedTabView()
        .environment(AppState())
        .environment(SpeechService())
        .environment(ProgressService())
}
