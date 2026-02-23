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
    var inventoryData: Data?
    var equippedWeaponData: Data?
    var equippedArmorData: Data?
    var monstersKilled: Int
    var bossesKilled: Int

    var playerClass: PlayerClass {
        get { PlayerClass(rawValue: playerClassRaw) ?? .warrior }
        set { playerClassRaw = newValue.rawValue }
    }

    // Inventaire encode en JSON dans SwiftData
    var inventory: [Item] {
        get {
            guard let data = inventoryData else { return [] }
            return (try? JSONDecoder().decode([Item].self, from: data)) ?? []
        }
        set {
            inventoryData = try? JSONEncoder().encode(newValue)
        }
    }

    var equippedWeapon: Item? {
        get {
            guard let data = equippedWeaponData else { return nil }
            return try? JSONDecoder().decode(Item.self, from: data)
        }
        set {
            equippedWeaponData = newValue != nil ? try? JSONEncoder().encode(newValue) : nil
        }
    }

    var equippedArmor: Item? {
        get {
            guard let data = equippedArmorData else { return nil }
            return try? JSONDecoder().decode(Item.self, from: data)
        }
        set {
            equippedArmorData = newValue != nil ? try? JSONEncoder().encode(newValue) : nil
        }
    }

    // Stats effectives (base + equipement)
    var totalAttack: Int {
        attack + (equippedWeapon?.attackBonus ?? 0) + (equippedArmor?.attackBonus ?? 0)
    }

    var totalDefense: Int {
        defense + (equippedWeapon?.defenseBonus ?? 0) + (equippedArmor?.defenseBonus ?? 0)
    }

    var totalSpeed: Int {
        speed + (equippedWeapon?.speedBonus ?? 0) + (equippedArmor?.speedBonus ?? 0)
    }

    var totalMaxHP: Int {
        maxHP + (equippedWeapon?.hpBonus ?? 0) + (equippedArmor?.hpBonus ?? 0)
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
        self.inventoryData = nil
        self.equippedWeaponData = nil
        self.equippedArmorData = nil
        self.monstersKilled = 0
        self.bossesKilled = 0
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

    // MARK: - Equipement

    func equip(_ item: Item) {
        switch item.type {
        case .weapon:
            if let old = equippedWeapon {
                var inv = inventory
                inv.append(old)
                inventory = inv
            }
            equippedWeapon = item
            removeFromInventory(item)
        case .armor:
            if let old = equippedArmor {
                var inv = inventory
                inv.append(old)
                inventory = inv
            }
            equippedArmor = item
            removeFromInventory(item)
        case .potion:
            break
        }
    }

    func unequipWeapon() {
        guard let weapon = equippedWeapon else { return }
        var inv = inventory
        inv.append(weapon)
        inventory = inv
        equippedWeapon = nil
    }

    func unequipArmor() {
        guard let armor = equippedArmor else { return }
        var inv = inventory
        inv.append(armor)
        inventory = inv
        equippedArmor = nil
    }

    func usePotion(_ item: Item) {
        guard item.type == .potion else { return }
        if item.id.contains("mana") {
            restoreMana(item.healAmount)
        } else {
            heal(item.healAmount)
        }
        removeFromInventory(item)
    }

    func removeFromInventory(_ item: Item) {
        var inv = inventory
        if let index = inv.firstIndex(where: { $0.id == item.id }) {
            inv.remove(at: index)
            inventory = inv
        }
    }

    func addToInventory(_ item: Item) {
        var inv = inventory
        inv.append(item)
        inventory = inv
    }
}
