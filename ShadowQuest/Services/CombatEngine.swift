// CombatEngine.swift
// ShadowQuest
//
// Moteur de combat — toute la logique tour par tour

import Foundation

enum CombatAction {
    case attack
    case skill(Skill)
    case usePotion(Item)
}

struct CombatResult {
    let damage: Int
    let isCritical: Bool
    let skillUsed: Skill?
    let healAmount: Int
    let attackerName: String
}

final class CombatEngine {

    static func calculateDamage(attackerATK: Int, defenderDEF: Int, skillDamage: Int, attackerClass: PlayerClass? = nil) -> (damage: Int, isCritical: Bool) {
        let baseDamage = Double(attackerATK) + Double(skillDamage)
        let reduction = Double(defenderDEF) * Constants.defenseReduction
        var finalDamage = max(Double(Constants.minDamage), baseDamage - reduction)

        let variation = Double.random(in: 0.85...1.15)
        finalDamage *= variation

        var critChance = Constants.baseCritChance
        if attackerClass == .assassin { critChance = 0.20 }
        let isCritical = Double.random(in: 0...1) < critChance
        if isCritical { finalDamage *= Constants.criticalMultiplier }

        return (max(Constants.minDamage, Int(finalDamage)), isCritical)
    }

    static func playerAction(_ action: CombatAction, player: Player, monster: inout Monster) -> CombatResult {
        switch action {
        case .attack:
            let (damage, crit) = calculateDamage(attackerATK: player.totalAttack, defenderDEF: monster.defense, skillDamage: 0, attackerClass: player.playerClass)
            monster.takeDamage(damage)
            return CombatResult(damage: damage, isCritical: crit, skillUsed: nil, healAmount: 0, attackerName: player.name)

        case .skill(let skill):
            if skill.isHeal {
                let healAmount = abs(skill.damage)
                player.heal(healAmount)
                player.currentMana -= skill.manaCost
                return CombatResult(damage: 0, isCritical: false, skillUsed: skill, healAmount: healAmount, attackerName: player.name)
            } else {
                let (damage, crit) = calculateDamage(attackerATK: player.totalAttack, defenderDEF: monster.defense, skillDamage: skill.damage, attackerClass: player.playerClass)
                monster.takeDamage(damage)
                player.currentMana -= skill.manaCost
                return CombatResult(damage: damage, isCritical: crit, skillUsed: skill, healAmount: 0, attackerName: player.name)
            }

        case .usePotion(let potion):
            if potion.id.contains("mana") {
                player.restoreMana(potion.healAmount)
            } else {
                player.heal(potion.healAmount)
            }
            player.removeFromInventory(potion)
            return CombatResult(damage: 0, isCritical: false, skillUsed: nil, healAmount: potion.healAmount, attackerName: player.name)
        }
    }

    static func monsterAction(monster: Monster, player: Player) -> CombatResult {
        let skill = monster.skills.randomElement()
        if let skill {
            let (damage, crit) = calculateDamage(attackerATK: monster.attack, defenderDEF: player.totalDefense, skillDamage: skill.damage)
            player.currentHP = max(0, player.currentHP - damage)
            return CombatResult(damage: damage, isCritical: crit, skillUsed: skill, healAmount: 0, attackerName: monster.name)
        } else {
            let (damage, crit) = calculateDamage(attackerATK: monster.attack, defenderDEF: player.totalDefense, skillDamage: 0)
            player.currentHP = max(0, player.currentHP - damage)
            return CombatResult(damage: damage, isCritical: crit, skillUsed: nil, healAmount: 0, attackerName: monster.name)
        }
    }

    static func generateLoot(from monster: Monster) -> [Item] {
        monster.lootTable.compactMap { drop in
            Double.random(in: 0...1) <= drop.chance ? drop.item : nil
        }
    }

    static func playerGoesFirst(playerSpeed: Int, monsterSpeed: Int) -> Bool {
        playerSpeed >= monsterSpeed
    }
}
