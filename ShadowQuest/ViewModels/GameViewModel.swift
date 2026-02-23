// GameViewModel.swift
// ShadowQuest
//
// ViewModel principal — gere l'etat global du jeu

import Foundation
import SwiftData

enum GameScreen: Hashable {
    case mainMenu
    case characterCreation
    case worldMap
    case combat
    case inventory
}

@Observable
final class GameViewModel {
    var currentScreen: GameScreen = .mainMenu
    var gameState: GameState?
    var navigationPath: [GameScreen] = []
    var showContinueButton: Bool = false
    var isLoading: Bool = false

    private let dataService: DataService

    init(dataService: DataService = DataService()) {
        self.dataService = dataService
    }

    func configure(with modelContext: ModelContext) {
        dataService.configure(with: modelContext)
        showContinueButton = dataService.hasSavedGame()
    }

    // MARK: - Navigation

    func navigateTo(_ screen: GameScreen) {
        navigationPath.append(screen)
    }

    func goBack() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    // MARK: - Gestion de partie

    func startNewGame(name: String, playerClass: PlayerClass) {
        gameState = dataService.createNewGame(name: name, playerClass: playerClass)
        if gameState != nil {
            navigationPath = [.worldMap]
        }
    }

    func continueGame() {
        gameState = dataService.loadActiveGame()
        if gameState != nil {
            navigationPath = [.worldMap]
        }
    }

    func saveGame() {
        guard let gameState else { return }
        dataService.saveGame(gameState)
    }

    func deleteCurrentGame() {
        guard let gameState else { return }
        dataService.deleteGame(gameState)
        self.gameState = nil
        navigationPath = []
        showContinueButton = dataService.hasSavedGame()
    }

    // MARK: - Acces au joueur

    var player: Player? {
        gameState?.player
    }

    var playerName: String {
        player?.name ?? "Inconnu"
    }

    var playerLevel: Int {
        player?.level ?? 1
    }
}
