// ContentView.swift
// ShadowQuest
//
// Vue racine — gere la navigation principale

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameVM = GameViewModel()

    var body: some View {
        @Bindable var vm = gameVM

        NavigationStack(path: $vm.navigationPath) {
            MainMenuView()
                .navigationDestination(for: GameScreen.self) { screen in
                    switch screen {
                    case .mainMenu:
                        MainMenuView()
                    case .characterCreation:
                        CharacterCreationView()
                    case .worldMap:
                        WorldMapView()
                    case .combat:
                        // Phase 3
                        Text("Combat — Phase 3")
                            .foregroundStyle(Theme.textPrimary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Theme.background)
                    case .inventory:
                        // Phase 4
                        Text("Inventaire — Phase 4")
                            .foregroundStyle(Theme.textPrimary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Theme.background)
                    }
                }
        }
        .environment(gameVM)
        .onAppear {
            gameVM.configure(with: modelContext)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Player.self, GameState.self], inMemory: true)
}
