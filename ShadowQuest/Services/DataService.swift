// DataService.swift
// ShadowQuest
//
// Service de persistance — gere SwiftData (sauvegarde/chargement)

import Foundation
import SwiftData

@Observable
final class DataService {
    private var modelContext: ModelContext?

    func configure(with modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Nouvelle partie

    func createNewGame(name: String, playerClass: PlayerClass) -> GameState? {
        guard let modelContext else { return nil }

        let player = Player(name: name, playerClass: playerClass)
        modelContext.insert(player)

        let gameState = GameState(player: player)
        modelContext.insert(gameState)

        return gameState
    }

    // MARK: - Charger la partie

    func loadActiveGame() -> GameState? {
        guard let modelContext else { return nil }

        let descriptor = FetchDescriptor<GameState>(
            predicate: #Predicate<GameState> { $0.isActive },
            sortBy: [SortDescriptor(\.saveDate, order: .reverse)]
        )

        let results = (try? modelContext.fetch(descriptor)) ?? []
        return results.first
    }

    func hasSavedGame() -> Bool {
        loadActiveGame() != nil
    }

    // MARK: - Sauvegarder

    func saveGame(_ gameState: GameState) {
        gameState.updateSaveDate()
        // SwiftData auto-save — pas besoin d'appel explicite
    }

    // MARK: - Supprimer

    func deleteGame(_ gameState: GameState) {
        guard let modelContext else { return }
        if let player = gameState.player {
            modelContext.delete(player)
        }
        modelContext.delete(gameState)
    }

    func deleteAllGames() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<GameState>()
        guard let allGames = try? modelContext.fetch(descriptor) else { return }

        for game in allGames {
            if let player = game.player {
                modelContext.delete(player)
            }
            modelContext.delete(game)
        }
    }
}
