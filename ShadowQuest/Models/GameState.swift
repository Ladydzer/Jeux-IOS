// GameState.swift
// ShadowQuest
//
// Etat global de la partie — persiste avec SwiftData

import Foundation
import SwiftData

@Model
final class GameState {
    var player: Player?
    var currentNodeId: String
    var unlockedNodeIds: [String]
    var defeatedBossIds: [String]
    var playTimeSeconds: Double
    var saveDate: Date
    var isActive: Bool

    init(
        player: Player? = nil,
        currentNodeId: String = "start",
        unlockedNodeIds: [String] = ["start"],
        defeatedBossIds: [String] = [],
        playTimeSeconds: Double = 0,
        saveDate: Date = .now,
        isActive: Bool = true
    ) {
        self.player = player
        self.currentNodeId = currentNodeId
        self.unlockedNodeIds = unlockedNodeIds
        self.defeatedBossIds = defeatedBossIds
        self.playTimeSeconds = playTimeSeconds
        self.saveDate = saveDate
        self.isActive = isActive
    }

    var formattedPlayTime: String {
        let hours = Int(playTimeSeconds) / 3600
        let minutes = (Int(playTimeSeconds) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        }
        return "\(minutes)min"
    }

    func updateSaveDate() {
        saveDate = .now
    }
}
