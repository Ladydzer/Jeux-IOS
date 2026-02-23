// CombatViewModel.swift
// ShadowQuest
//
// ViewModel de combat — pont entre SwiftUI et SpriteKit

import Foundation

enum CombatState {
    case playerTurn
    case monsterTurn
    case victory
    case defeat
    case animating
}

@Observable
final class CombatViewModel {
    var monster: Monster
    var combatState: CombatState = .playerTurn
    var combatLog: [String] = []
    var turnCount: Int = 1
    var showPotionPicker: Bool = false
    var shakeMonster: Bool = false
    var shakePlayer: Bool = false
    var lastPlayerResult: CombatResult?
    var lastMonsterResult: CombatResult?

    private let player: Player
    let playerSkills: [Skill]

    init(player: Player, node: MapNode) {
        self.player = player
        self.monster = MonsterCatalog.monsterForNode(node)
        self.playerSkills = SkillCatalog.skillsFor(player.playerClass)

        if CombatEngine.playerGoesFirst(playerSpeed: player.totalSpeed, monsterSpeed: monster.speed) {
            combatState = .playerTurn
            addLog("Le combat commence ! Tu attaques en premier.")
        } else {
            combatState = .monsterTurn
            addLog("\(self.monster.name) est plus rapide !")
            performMonsterTurn()
        }
    }

    var potions: [Item] {
        player.inventory.filter { $0.type == .potion }
    }

    func canAffordSkill(_ skill: Skill) -> Bool {
        player.currentMana >= skill.manaCost
    }

    // MARK: - Actions joueur

    func playerAttack() {
        guard combatState == .playerTurn else { return }
        combatState = .animating

        let result = CombatEngine.playerAction(.attack, player: player, monster: &monster)
        lastPlayerResult = result
        shakeMonster = true

        var msg = "\(player.name) attaque ! \(result.damage) degats"
        if result.isCritical { msg += " CRITIQUE!" }
        addLog(msg)
        checkCombatEnd(afterPlayerTurn: true)
    }

    func playerUseSkill(_ skill: Skill) {
        guard combatState == .playerTurn, canAffordSkill(skill) else { return }
        combatState = .animating

        let result = CombatEngine.playerAction(.skill(skill), player: player, monster: &monster)
        lastPlayerResult = result
        if !skill.isHeal { shakeMonster = true }

        if skill.isHeal {
            addLog("\(player.name) utilise \(skill.name) ! +\(result.healAmount) PV")
        } else {
            var msg = "\(player.name) lance \(skill.name) ! \(result.damage) degats"
            if result.isCritical { msg += " CRITIQUE!" }
            addLog(msg)
        }
        checkCombatEnd(afterPlayerTurn: true)
    }

    func playerUsePotion(_ potion: Item) {
        guard combatState == .playerTurn else { return }
        combatState = .animating
        showPotionPicker = false

        let result = CombatEngine.playerAction(.usePotion(potion), player: player, monster: &monster)
        lastPlayerResult = result

        let resource = potion.id.contains("mana") ? "Mana" : "PV"
        addLog("\(player.name) utilise \(potion.name) ! +\(result.healAmount) \(resource)")
        checkCombatEnd(afterPlayerTurn: true)
    }

    // MARK: - Tour monstre

    private func performMonsterTurn() {
        guard monster.isAlive, player.isAlive else { return }
        combatState = .monsterTurn

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [self] in
            let result = CombatEngine.monsterAction(monster: monster, player: player)
            lastMonsterResult = result
            shakePlayer = true

            var msg = "\(monster.name)"
            if let skill = result.skillUsed {
                msg += " utilise \(skill.name) !"
            } else {
                msg += " attaque !"
            }
            msg += " \(result.damage) degats"
            if result.isCritical { msg += " CRITIQUE!" }
            addLog(msg)
            turnCount += 1
            checkCombatEnd(afterPlayerTurn: false)
        }
    }

    private func checkCombatEnd(afterPlayerTurn: Bool) {
        if !monster.isAlive {
            combatState = .victory
            player.monstersKilled += 1
            if monster.isBoss { player.bossesKilled += 1 }
            addLog("\(monster.name) est vaincu !")
            return
        }
        if !player.isAlive {
            combatState = .defeat
            addLog("\(player.name) est tombe...")
            return
        }
        if afterPlayerTurn {
            performMonsterTurn()
        } else {
            combatState = .playerTurn
        }
    }

    func generateRewards() -> CombatRewards {
        let loot = CombatEngine.generateLoot(from: monster)
        return CombatRewards(xpGained: monster.xpReward, goldGained: monster.goldReward, itemsLooted: loot)
    }

    private func addLog(_ message: String) {
        combatLog.insert(message, at: 0)
        if combatLog.count > 20 { combatLog.removeLast() }
    }
}
