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
                        CombatView()
                    case .inventory:
                        InventoryView()
                    case .merchant(let zone):
                        MerchantView(zone: zone)
                    case .gameOver:
                        GameOverView()
                    case .victory:
                        VictoryView()
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
