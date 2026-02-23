// Constants.swift
// ShadowQuest
//
// Constantes globales du jeu

import Foundation

enum Constants {
    static let gameName = "ShadowQuest"

    // Niveaux
    static let maxLevel = 50
    static let baseXPToLevel = 100 // XP pour passer du niveau 1 au 2
    static let xpMultiplier = 1.5  // Chaque niveau demande 1.5x plus d'XP

    // Economie
    static let startingGold = 100

    // Stats de base par classe (HP, Mana, ATK, DEF, SPD)
    enum Warrior {
        static let baseHP = 120
        static let baseMana = 40
        static let baseAttack = 15
        static let baseDefense = 12
        static let baseSpeed = 8
        static let hpPerLevel = 12
        static let manaPerLevel = 3
        static let attackPerLevel = 3
        static let defensePerLevel = 2
        static let speedPerLevel = 1
    }

    enum Mage {
        static let baseHP = 70
        static let baseMana = 100
        static let baseAttack = 8
        static let baseDefense = 6
        static let baseSpeed = 10
        static let hpPerLevel = 6
        static let manaPerLevel = 10
        static let attackPerLevel = 2
        static let defensePerLevel = 1
        static let speedPerLevel = 2
    }

    enum Assassin {
        static let baseHP = 85
        static let baseMana = 60
        static let baseAttack = 13
        static let baseDefense = 7
        static let baseSpeed = 15
        static let hpPerLevel = 8
        static let manaPerLevel = 5
        static let attackPerLevel = 3
        static let defensePerLevel = 1
        static let speedPerLevel = 3
    }

    // Combat
    static let criticalMultiplier = 1.5
    static let baseCritChance = 0.05 // 5%
    static let defenseReduction = 0.5 // DEF reduit les degats de 50% de sa valeur
    static let minDamage = 1 // Degats minimum garantis

    // Potions
    static let smallPotionHeal = 30
    static let mediumPotionHeal = 60
    static let largePotionHeal = 120
}
