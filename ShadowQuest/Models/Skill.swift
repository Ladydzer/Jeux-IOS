// Skill.swift
// ShadowQuest
//
// Modele des competences de combat

import Foundation

enum SkillTarget: String, Codable {
    case single
    case allEnemies
    case selfTarget
}

struct Skill: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let damage: Int       // Negatif = soin
    let manaCost: Int
    let cooldown: Int     // Nombre de tours avant reutilisation
    let target: SkillTarget
    let requiredClass: String

    var isHeal: Bool {
        damage < 0
    }
}

enum SkillCatalog {
    // -- Guerrier --
    static let heavySlash = Skill(
        id: "warrior_heavy_slash",
        name: "Frappe Lourde",
        description: "Un coup d'epee devastateur.",
        damage: 25,
        manaCost: 10,
        cooldown: 0,
        target: .single,
        requiredClass: PlayerClass.warrior.rawValue
    )

    static let shieldBash = Skill(
        id: "warrior_shield_bash",
        name: "Coup de Bouclier",
        description: "Frappe avec le bouclier. Degats moyens.",
        damage: 15,
        manaCost: 8,
        cooldown: 1,
        target: .single,
        requiredClass: PlayerClass.warrior.rawValue
    )

    static let warCry = Skill(
        id: "warrior_war_cry",
        name: "Cri de Guerre",
        description: "Renforce l'attaque pour le prochain tour.",
        damage: 0,
        manaCost: 15,
        cooldown: 3,
        target: .selfTarget,
        requiredClass: PlayerClass.warrior.rawValue
    )

    // -- Mage --
    static let fireball = Skill(
        id: "mage_fireball",
        name: "Boule de Feu",
        description: "Projette une boule de feu brulante.",
        damage: 30,
        manaCost: 20,
        cooldown: 0,
        target: .single,
        requiredClass: PlayerClass.mage.rawValue
    )

    static let iceStorm = Skill(
        id: "mage_ice_storm",
        name: "Tempete de Glace",
        description: "Declenche une tempete qui frappe tous les ennemis.",
        damage: 18,
        manaCost: 30,
        cooldown: 2,
        target: .allEnemies,
        requiredClass: PlayerClass.mage.rawValue
    )

    static let heal = Skill(
        id: "mage_heal",
        name: "Soin",
        description: "Restaure des points de vie.",
        damage: -35,
        manaCost: 25,
        cooldown: 2,
        target: .selfTarget,
        requiredClass: PlayerClass.mage.rawValue
    )

    // -- Assassin --
    static let backstab = Skill(
        id: "assassin_backstab",
        name: "Coup dans le Dos",
        description: "Attaque furtive avec chance de critique augmentee.",
        damage: 22,
        manaCost: 12,
        cooldown: 0,
        target: .single,
        requiredClass: PlayerClass.assassin.rawValue
    )

    static let poisonBlade = Skill(
        id: "assassin_poison_blade",
        name: "Lame Empoisonnee",
        description: "Enduit la lame de poison. Degats sur la duree.",
        damage: 15,
        manaCost: 18,
        cooldown: 2,
        target: .single,
        requiredClass: PlayerClass.assassin.rawValue
    )

    static let shadowStep = Skill(
        id: "assassin_shadow_step",
        name: "Pas de l'Ombre",
        description: "Se teleporte dans l'ombre. Esquive le prochain coup.",
        damage: 0,
        manaCost: 20,
        cooldown: 3,
        target: .selfTarget,
        requiredClass: PlayerClass.assassin.rawValue
    )

    static func skillsFor(_ playerClass: PlayerClass) -> [Skill] {
        switch playerClass {
        case .warrior:
            return [heavySlash, shieldBash, warCry]
        case .mage:
            return [fireball, iceStorm, heal]
        case .assassin:
            return [backstab, poisonBlade, shadowStep]
        }
    }
}
