// ShadowQuestApp.swift
// ShadowQuest
//
// Point d'entree de l'application

import SwiftUI
import SwiftData

@main
struct ShadowQuestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Player.self, GameState.self])
    }
}
