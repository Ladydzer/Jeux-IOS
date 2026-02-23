// Item.swift
// ShadowQuest
//
// Modele des objets (armes, armures, potions)

import Foundation

enum ItemType: String, Codable, CaseIterable {
    case weapon = "Arme"
    case armor = "Armure"
    case potion = "Potion"
}

enum ItemRarity: String, Codable, CaseIterable {
    case common = "Commun"
    case uncommon = "Peu commun"
    case rare = "Rare"
    case epic = "Epique"
    case legendary = "Legendaire"

    var sortOrder: Int {
        switch self {
        case .common: return 0
        case .uncommon: return 1
        case .rare: return 2
        case .epic: return 3
        case .legendary: return 4
        }
    }
}

struct Item: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let type: ItemType
    let rarity: ItemRarity
    let price: Int

    // Stats bonus (pour armes et armures)
    let attackBonus: Int
    let defenseBonus: Int
    let speedBonus: Int
    let hpBonus: Int

    // Potion
    let healAmount: Int

    var icon: String {
        switch type {
        case .weapon: return "⚔️"
        case .armor: return "🛡️"
        case .potion: return "🧪"
        }
    }

    static func == (lhs: Item, rhs: Item) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Catalogue d'items

enum ItemCatalog {
    // -- Potions --
    static let smallPotion = Item(
        id: "potion_small", name: "Petite Potion", description: "Restaure 30 PV.",
        type: .potion, rarity: .common, price: 25,
        attackBonus: 0, defenseBonus: 0, speedBonus: 0, hpBonus: 0,
        healAmount: Constants.smallPotionHeal
    )

    static let mediumPotion = Item(
        id: "potion_medium", name: "Potion Moyenne", description: "Restaure 60 PV.",
        type: .potion, rarity: .uncommon, price: 60,
        attackBonus: 0, defenseBonus: 0, speedBonus: 0, hpBonus: 0,
        healAmount: Constants.mediumPotionHeal
    )

    static let largePotionItem = Item(
        id: "potion_large", name: "Grande Potion", description: "Restaure 120 PV.",
        type: .potion, rarity: .rare, price: 120,
        attackBonus: 0, defenseBonus: 0, speedBonus: 0, hpBonus: 0,
        healAmount: Constants.largePotionHeal
    )

    static let manaPotion = Item(
        id: "potion_mana", name: "Potion de Mana", description: "Restaure 40 mana.",
        type: .potion, rarity: .uncommon, price: 50,
        attackBonus: 0, defenseBonus: 0, speedBonus: 0, hpBonus: 0,
        healAmount: 40
    )

    // -- Armes --
    static let ironSword = Item(
        id: "weapon_iron_sword", name: "Epee de Fer", description: "Une epee basique mais fiable.",
        type: .weapon, rarity: .common, price: 80,
        attackBonus: 5, defenseBonus: 0, speedBonus: 0, hpBonus: 0,
        healAmount: 0
    )

    static let steelSword = Item(
        id: "weapon_steel_sword", name: "Epee d'Acier", description: "Lame aiguisee et resistante.",
        type: .weapon, rarity: .uncommon, price: 180,
        attackBonus: 10, defenseBonus: 0, speedBonus: 1, hpBonus: 0,
        healAmount: 0
    )

    static let darkBlade = Item(
        id: "weapon_dark_blade", name: "Lame Sombre", description: "Forgee dans l'ombre, elle vibre de puissance.",
        type: .weapon, rarity: .rare, price: 350,
        attackBonus: 18, defenseBonus: 0, speedBonus: 2, hpBonus: 0,
        healAmount: 0
    )

    static let shadowBlade = Item(
        id: "weapon_shadow_blade", name: "Lame du Neant", description: "L'arme du Seigneur des Ombres lui-meme.",
        type: .weapon, rarity: .legendary, price: 800,
        attackBonus: 30, defenseBonus: 5, speedBonus: 5, hpBonus: 10,
        healAmount: 0
    )

    static let wizardStaff = Item(
        id: "weapon_wizard_staff", name: "Baton de Mage", description: "Canalise l'energie arcanique.",
        type: .weapon, rarity: .uncommon, price: 200,
        attackBonus: 12, defenseBonus: 0, speedBonus: 0, hpBonus: 0,
        healAmount: 0
    )

    static let assassinDagger = Item(
        id: "weapon_dagger", name: "Dague de l'Ombre", description: "Rapide et silencieuse.",
        type: .weapon, rarity: .uncommon, price: 160,
        attackBonus: 8, defenseBonus: 0, speedBonus: 5, hpBonus: 0,
        healAmount: 0
    )

    // -- Armures --
    static let leatherArmor = Item(
        id: "armor_leather", name: "Armure de Cuir", description: "Protection legere et souple.",
        type: .armor, rarity: .common, price: 100,
        attackBonus: 0, defenseBonus: 5, speedBonus: 0, hpBonus: 10,
        healAmount: 0
    )

    static let chainmail = Item(
        id: "armor_chainmail", name: "Cotte de Mailles", description: "Mailles d'acier entrelacees.",
        type: .armor, rarity: .uncommon, price: 250,
        attackBonus: 0, defenseBonus: 10, speedBonus: -1, hpBonus: 20,
        healAmount: 0
    )

    static let plateArmor = Item(
        id: "armor_plate", name: "Armure de Plates", description: "Protection maximale en acier trempe.",
        type: .armor, rarity: .rare, price: 450,
        attackBonus: 0, defenseBonus: 18, speedBonus: -3, hpBonus: 40,
        healAmount: 0
    )

    static let shadowCloak = Item(
        id: "armor_shadow_cloak", name: "Cape des Ombres", description: "Tissee de tenebres pures.",
        type: .armor, rarity: .epic, price: 600,
        attackBonus: 5, defenseBonus: 12, speedBonus: 5, hpBonus: 25,
        healAmount: 0
    )

    static let mageRobe = Item(
        id: "armor_mage_robe", name: "Robe Arcanique", description: "Impregnee de magie protectrice.",
        type: .armor, rarity: .uncommon, price: 200,
        attackBonus: 3, defenseBonus: 6, speedBonus: 2, hpBonus: 15,
        healAmount: 0
    )

    // Items du marchand par zone
    static func merchantItems(for zone: Zone) -> [Item] {
        switch zone {
        case .cursedForest:
            return [smallPotion, mediumPotion, manaPotion, ironSword, leatherArmor]
        case .crypts:
            return [mediumPotion, largePotionItem, manaPotion, steelSword, wizardStaff, chainmail, mageRobe]
        case .citadel:
            return [largePotionItem, manaPotion, darkBlade, assassinDagger, plateArmor, shadowCloak]
        }
    }
}
