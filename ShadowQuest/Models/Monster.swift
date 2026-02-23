// Monster.swift
// ShadowQuest
//
// Modele des monstres ennemis

import Foundation

struct Monster: Identifiable {
    let id: String
    let name: String
    let zone: Zone
    let level: Int
    var currentHP: Int
    let maxHP: Int
    let attack: Int
    let defense: Int
    let speed: Int
    let xpReward: Int
    let goldReward: Int
    let skills: [Skill]
    let lootTable: [LootDrop]
    let isBoss: Bool
    let icon: String

    var isAlive: Bool { currentHP > 0 }

    var hpPercent: Double {
        guard maxHP > 0 else { return 0 }
        return Double(currentHP) / Double(maxHP)
    }

    mutating func takeDamage(_ amount: Int) {
        currentHP = max(0, currentHP - amount)
    }
}

struct LootDrop {
    let item: Item
    let chance: Double
}

// MARK: - Catalogue de monstres

enum MonsterCatalog {
    // -- Foret Maudite --
    static func goblin() -> Monster {
        Monster(id: "goblin", name: "Gobelin", zone: .cursedForest, level: 1,
                currentHP: 35, maxHP: 35, attack: 8, defense: 3, speed: 10,
                xpReward: 25, goldReward: 15,
                skills: [MonsterSkills.scratch],
                lootTable: [LootDrop(item: ItemCatalog.smallPotion, chance: 0.3)],
                isBoss: false, icon: "👺")
    }

    static func wolf() -> Monster {
        Monster(id: "wolf", name: "Loup Sombre", zone: .cursedForest, level: 2,
                currentHP: 50, maxHP: 50, attack: 12, defense: 5, speed: 14,
                xpReward: 40, goldReward: 20,
                skills: [MonsterSkills.bite, MonsterSkills.scratch],
                lootTable: [LootDrop(item: ItemCatalog.smallPotion, chance: 0.4)],
                isBoss: false, icon: "🐺")
    }

    static func treant() -> Monster {
        Monster(id: "treant", name: "Treant Corrompu", zone: .cursedForest, level: 3,
                currentHP: 80, maxHP: 80, attack: 10, defense: 12, speed: 4,
                xpReward: 55, goldReward: 30,
                skills: [MonsterSkills.slam, MonsterSkills.rootGrip],
                lootTable: [
                    LootDrop(item: ItemCatalog.mediumPotion, chance: 0.3),
                    LootDrop(item: ItemCatalog.ironSword, chance: 0.15)
                ],
                isBoss: false, icon: "🌳")
    }

    static func forestGuardian() -> Monster {
        Monster(id: "boss_forest_guardian", name: "Gardien de la Foret", zone: .cursedForest, level: 5,
                currentHP: 180, maxHP: 180, attack: 18, defense: 14, speed: 8,
                xpReward: 150, goldReward: 100,
                skills: [MonsterSkills.slam, MonsterSkills.rootGrip, MonsterSkills.natureFury],
                lootTable: [
                    LootDrop(item: ItemCatalog.steelSword, chance: 0.5),
                    LootDrop(item: ItemCatalog.leatherArmor, chance: 0.5),
                    LootDrop(item: ItemCatalog.largePotionItem, chance: 1.0)
                ],
                isBoss: true, icon: "🌿")
    }

    // -- Cryptes --
    static func skeleton() -> Monster {
        Monster(id: "skeleton", name: "Squelette", zone: .crypts, level: 4,
                currentHP: 55, maxHP: 55, attack: 14, defense: 8, speed: 9,
                xpReward: 50, goldReward: 25,
                skills: [MonsterSkills.boneStrike],
                lootTable: [LootDrop(item: ItemCatalog.smallPotion, chance: 0.3)],
                isBoss: false, icon: "💀")
    }

    static func ghost() -> Monster {
        Monster(id: "ghost", name: "Spectre", zone: .crypts, level: 5,
                currentHP: 45, maxHP: 45, attack: 18, defense: 4, speed: 16,
                xpReward: 65, goldReward: 35,
                skills: [MonsterSkills.shadowBolt, MonsterSkills.lifeDrain],
                lootTable: [LootDrop(item: ItemCatalog.mediumPotion, chance: 0.4)],
                isBoss: false, icon: "👻")
    }

    static func vampire() -> Monster {
        Monster(id: "vampire", name: "Vampire", zone: .crypts, level: 6,
                currentHP: 90, maxHP: 90, attack: 20, defense: 10, speed: 13,
                xpReward: 80, goldReward: 50,
                skills: [MonsterSkills.bite, MonsterSkills.lifeDrain, MonsterSkills.shadowBolt],
                lootTable: [
                    LootDrop(item: ItemCatalog.mediumPotion, chance: 0.4),
                    LootDrop(item: ItemCatalog.steelSword, chance: 0.1)
                ],
                isBoss: false, icon: "🧛")
    }

    static func lichKing() -> Monster {
        Monster(id: "boss_lich_king", name: "Roi Liche", zone: .crypts, level: 8,
                currentHP: 280, maxHP: 280, attack: 25, defense: 16, speed: 10,
                xpReward: 300, goldReward: 200,
                skills: [MonsterSkills.shadowBolt, MonsterSkills.lifeDrain, MonsterSkills.deathWave],
                lootTable: [
                    LootDrop(item: ItemCatalog.darkBlade, chance: 0.4),
                    LootDrop(item: ItemCatalog.chainmail, chance: 0.5),
                    LootDrop(item: ItemCatalog.largePotionItem, chance: 1.0)
                ],
                isBoss: true, icon: "👑")
    }

    // -- Citadelle --
    static func darkKnight() -> Monster {
        Monster(id: "dark_knight", name: "Chevalier Noir", zone: .citadel, level: 8,
                currentHP: 120, maxHP: 120, attack: 24, defense: 18, speed: 8,
                xpReward: 100, goldReward: 60,
                skills: [MonsterSkills.slam, MonsterSkills.boneStrike],
                lootTable: [
                    LootDrop(item: ItemCatalog.mediumPotion, chance: 0.4),
                    LootDrop(item: ItemCatalog.chainmail, chance: 0.1)
                ],
                isBoss: false, icon: "🗡️")
    }

    static func demon() -> Monster {
        Monster(id: "demon", name: "Demon", zone: .citadel, level: 10,
                currentHP: 150, maxHP: 150, attack: 28, defense: 14, speed: 12,
                xpReward: 130, goldReward: 80,
                skills: [MonsterSkills.shadowBolt, MonsterSkills.natureFury, MonsterSkills.lifeDrain],
                lootTable: [
                    LootDrop(item: ItemCatalog.largePotionItem, chance: 0.3),
                    LootDrop(item: ItemCatalog.darkBlade, chance: 0.1)
                ],
                isBoss: false, icon: "😈")
    }

    static func shadowLord() -> Monster {
        Monster(id: "boss_shadow_lord", name: "Seigneur des Ombres", zone: .citadel, level: 12,
                currentHP: 450, maxHP: 450, attack: 35, defense: 22, speed: 14,
                xpReward: 500, goldReward: 500,
                skills: [MonsterSkills.shadowBolt, MonsterSkills.deathWave, MonsterSkills.lifeDrain, MonsterSkills.natureFury],
                lootTable: [
                    LootDrop(item: ItemCatalog.shadowBlade, chance: 0.6),
                    LootDrop(item: ItemCatalog.plateArmor, chance: 0.6),
                    LootDrop(item: ItemCatalog.largePotionItem, chance: 1.0)
                ],
                isBoss: true, icon: "🫅")
    }

    static func monsterForNode(_ node: MapNode) -> Monster {
        if node.type == .boss {
            switch node.zone {
            case .cursedForest: return forestGuardian()
            case .crypts: return lichKing()
            case .citadel: return shadowLord()
            }
        }
        switch node.zone {
        case .cursedForest:
            return [goblin(), wolf(), treant()].randomElement() ?? goblin()
        case .crypts:
            return [skeleton(), ghost(), vampire()].randomElement() ?? skeleton()
        case .citadel:
            return [darkKnight(), demon()].randomElement() ?? darkKnight()
        }
    }
}

enum MonsterSkills {
    static let scratch = Skill(id: "mon_scratch", name: "Griffure", description: "Griffe l'ennemi.", damage: 8, manaCost: 0, cooldown: 0, target: .single, requiredClass: "any")
    static let bite = Skill(id: "mon_bite", name: "Morsure", description: "Mord violemment.", damage: 12, manaCost: 0, cooldown: 0, target: .single, requiredClass: "any")
    static let slam = Skill(id: "mon_slam", name: "Ecrasement", description: "Ecrase avec force.", damage: 18, manaCost: 0, cooldown: 1, target: .single, requiredClass: "any")
    static let boneStrike = Skill(id: "mon_bone", name: "Frappe Osseuse", description: "Frappe avec un os.", damage: 15, manaCost: 0, cooldown: 0, target: .single, requiredClass: "any")
    static let shadowBolt = Skill(id: "mon_shadow", name: "Trait d'Ombre", description: "Energie sombre.", damage: 20, manaCost: 0, cooldown: 1, target: .single, requiredClass: "any")
    static let lifeDrain = Skill(id: "mon_drain", name: "Drain de Vie", description: "Vole de la vie.", damage: 12, manaCost: 0, cooldown: 2, target: .single, requiredClass: "any")
    static let rootGrip = Skill(id: "mon_root", name: "Emprise Racinaire", description: "Racines.", damage: 10, manaCost: 0, cooldown: 2, target: .single, requiredClass: "any")
    static let natureFury = Skill(id: "mon_fury", name: "Furie Naturelle", description: "Nature dechainee.", damage: 25, manaCost: 0, cooldown: 3, target: .single, requiredClass: "any")
    static let deathWave = Skill(id: "mon_death", name: "Vague de Mort", description: "Onde mortelle.", damage: 30, manaCost: 0, cooldown: 3, target: .single, requiredClass: "any")
}
