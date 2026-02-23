// Player.swift
// ShadowQuest
//
// Modele du joueur — persiste avec SwiftData

import Foundation
import SwiftData

enum PlayerClass: String, Codable, CaseIterable {
    case warrior = "Guerrier"
    case mage = "Mage"
    case assassin = "Assassin"

    var description: String {
        switch self {
        case .warrior:
            return "Resistant et puissant. Excelle en defense et degats physiques."
        case .mage:
            return "Fragile mais devastateur. Maitrise les elements et la magie de zone."
        case .assassin:
            return "Rapide et lethal. Frappe les points faibles avec precision."
        }
    }

    var baseHP: Int {
        switch self {
        case .warrior: return Constants.Warrior.baseHP
        case .mage: return Constants.Mage.baseHP
        case .assassin: return Constants.Assassin.baseHP
        }
    }

    var baseMana: Int {
        switch self {
        case .warrior: return Constants.Warrior.baseMana
        case .mage: return Constants.Mage.baseMana
        case .assassin: return Constants.Assassin.baseMana
        }
    }

    var baseAttack: Int {
        switch self {
        case .warrior: return Constants.Warrior.baseAttack
        case .mage: return Constants.Mage.baseAttack
        case .assassin: return Constants.Assassin.baseAttack
        }
    }

    var baseDefense: Int {
        switch self {
        case .warrior: return Constants.Warrior.baseDefense
        case .mage: return Constants.Mage.baseDefense
        case .assassin: return Constants.Assassin.baseDefense
        }
    }

    var baseSpeed: Int {
        switch self {
        case .warrior: return Constants.Warrior.baseSpeed
        case .mage: return Constants.Mage.baseSpeed
        case .assassin: return Constants.Assassin.baseSpeed
        }
    }

    var hpPerLevel: Int {
        switch self {
        case .warrior: return Constants.Warrior.hpPerLevel
        case .mage: return Constants.Mage.hpPerLevel
        case .assassin: return Constants.Assassin.hpPerLevel
        }
    }

    var manaPerLevel: Int {
        switch self {
        case .warrior: return Constants.Warrior.manaPerLevel
        case .mage: return Constants.Mage.manaPerLevel
        case .assassin: return Constants.Assassin.manaPerLevel
        }
    }

    var attackPerLevel: Int {
        switch self {
        case .warrior: return Constants.Warrior.attackPerLevel
        case .mage: return Constants.Mage.attackPerLevel
        case .assassin: return Constants.Assassin.attackPerLevel
        }
    }

    var defensePerLevel: Int {
        switch self {
        case .warrior: return Constants.Warrior.defensePerLevel
        case .mage: return Constants.Mage.defensePerLevel
        case .assassin: return Constants.Assassin.defensePerLevel
        }
    }

    var speedPerLevel: Int {
        switch self {
        case .warrior: return Constants.Warrior.speedPerLevel
        case .mage: return Constants.Mage.speedPerLevel
        case .assassin: return Constants.Assassin.speedPerLevel
        }
    }
}

@Model
final class Player {
    var name: String
    var playerClassRaw: String
    var level: Int
    var xp: Int
    var currentHP: Int
    var maxHP: Int
    var currentMana: Int
    var maxMana: Int
    var attack: Int
    var defense: Int
    var speed: Int
    var gold: Int

    var playerClass: PlayerClass {
        get { PlayerClass(rawValue: playerClassRaw) ?? .warrior }
        set { playerClassRaw = newValue.rawValue }
    }

    init(
        name: String = "",
        playerClass: PlayerClass = .warrior,
        level: Int = 1,
        xp: Int = 0,
        gold: Int = Constants.startingGold
    ) {
        self.name = name
        self.playerClassRaw = playerClass.rawValue
        self.level = level
        self.xp = xp
        self.maxHP = playerClass.baseHP
        self.currentHP = playerClass.baseHP
        self.maxMana = playerClass.baseMana
        self.currentMana = playerClass.baseMana
        self.attack = playerClass.baseAttack
        self.defense = playerClass.baseDefense
        self.speed = playerClass.baseSpeed
        self.gold = gold
    }

    var xpToNextLevel: Int {
        Int(Double(Constants.baseXPToLevel) * pow(Constants.xpMultiplier, Double(level - 1)))
    }

    var xpProgress: Double {
        guard xpToNextLevel > 0 else { return 0 }
        return Double(xp) / Double(xpToNextLevel)
    }

    var hpPercent: Double {
        guard maxHP > 0 else { return 0 }
        return Double(currentHP) / Double(maxHP)
    }

    var manaPercent: Double {
        guard maxMana > 0 else { return 0 }
        return Double(currentMana) / Double(maxMana)
    }

    var isAlive: Bool {
        currentHP > 0
    }

    func gainXP(_ amount: Int) {
        xp += amount
        while xp >= xpToNextLevel && level < Constants.maxLevel {
            xp -= xpToNextLevel
            levelUp()
        }
    }

    func levelUp() {
        level += 1
        let pc = playerClass
        maxHP += pc.hpPerLevel
        currentHP = maxHP
        maxMana += pc.manaPerLevel
        currentMana = maxMana
        attack += pc.attackPerLevel
        defense += pc.defensePerLevel
        speed += pc.speedPerLevel
    }

    func heal(_ amount: Int) {
        currentHP = min(currentHP + amount, maxHP)
    }

    func restoreMana(_ amount: Int) {
        currentMana = min(currentMana + amount, maxMana)
    }

    func fullRestore() {
        currentHP = maxHP
        currentMana = maxMana
    }
}
