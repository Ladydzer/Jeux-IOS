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
    case merchant(Zone)
    case gameOver
    case victory
}

@Observable
final class GameViewModel {
    var currentScreen: GameScreen = .mainMenu
    var gameState: GameState?
    var navigationPath: [GameScreen] = []
    var showContinueButton: Bool = false
    var isLoading: Bool = false

    // Combat
    var currentCombatNode: MapNode?
    var lastCombatRewards: CombatRewards?

    // Feedback
    var showLevelUpAlert: Bool = false
    var showRewardsSheet: Bool = false

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

    func returnToMap() {
        navigationPath = [.worldMap]
    }

    // MARK: - Gestion de partie

    func startNewGame(name: String, playerClass: PlayerClass) {
        gameState = dataService.createNewGame(name: name, playerClass: playerClass)
        if let gameState, let player = gameState.player {
            // Donner les potions de depart
            player.inventory.append(ItemCatalog.smallPotion)
            player.inventory.append(ItemCatalog.smallPotion)
            player.inventory.append(ItemCatalog.smallPotion)
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

    // MARK: - Combat

    func onCombatVictory(rewards: CombatRewards) {
        lastCombatRewards = rewards

        guard let player else { return }

        // XP
        let previousLevel = player.level
        player.gainXP(rewards.xpGained)
        if player.level > previousLevel {
            showLevelUpAlert = true
        }

        // Or
        player.gold += rewards.goldGained

        // Loot
        for item in rewards.itemsLooted {
            player.addToInventory(item)
        }

        // Debloquer les nodes suivants
        if let node = currentCombatNode {
            let mapVM = MapViewModel()
            mapVM.completeNode(node, gameState: gameState)

            // Victoire finale si boss de la Citadelle
            if node.type == .boss && node.zone == .citadel {
                saveGame()
                navigationPath = [.victory]
                return
            }
        }

        saveGame()
        showRewardsSheet = true
    }

    func onCombatDefeat() {
        navigationPath = [.gameOver]
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

struct CombatRewards {
    let xpGained: Int
    let goldGained: Int
    let itemsLooted: [Item]
}
