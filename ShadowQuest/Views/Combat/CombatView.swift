// CombatView.swift
// ShadowQuest
//
// Vue SwiftUI de combat — SpriteView + controles

import SwiftUI
import SpriteKit

struct CombatView: View {
    @Environment(GameViewModel.self) private var gameVM
    @State private var combatVM: CombatViewModel?
    @State private var scene: CombatScene?
    @State private var showRewards: Bool = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if let combatVM {
                VStack(spacing: 0) {
                    // Header: barres de vie
                    combatHeader(combatVM: combatVM)

                    // Scene SpriteKit
                    if let scene {
                        SpriteView(scene: scene)
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                            .padding(.horizontal, Theme.smallPadding)
                    }

                    // Log de combat
                    combatLogView(combatVM: combatVM)

                    Spacer()

                    // Controles
                    if combatVM.combatState == .playerTurn {
                        actionButtons(combatVM: combatVM)
                    } else if combatVM.combatState == .victory {
                        victoryButtons()
                    } else if combatVM.combatState == .defeat {
                        defeatButton()
                    } else {
                        Text("Tour de \(combatVM.monster.name)...")
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.textSecondary)
                            .padding()
                    }
                }
            } else {
                ProgressView()
                    .tint(Theme.primary)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear { setupCombat() }
        .onChange(of: combatVM?.shakeMonster) { _, newVal in
            if newVal == true {
                scene?.animatePlayerAttack()
                combatVM?.shakeMonster = false
            }
        }
        .onChange(of: combatVM?.shakePlayer) { _, newVal in
            if newVal == true {
                scene?.animateMonsterAttack()
                combatVM?.shakePlayer = false
            }
        }
        .onChange(of: combatVM?.combatState) { _, newState in
            if newState == .victory {
                scene?.animateMonsterDeath()
            }
        }
        .sheet(isPresented: Binding(
            get: { combatVM?.showPotionPicker ?? false },
            set: { combatVM?.showPotionPicker = $0 }
        )) {
            potionPicker()
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showRewards) {
            rewardsSheet()
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
        }
    }

    // MARK: - Setup

    private func setupCombat() {
        guard let player = gameVM.player, let node = gameVM.currentCombatNode else { return }

        let vm = CombatViewModel(player: player, node: node)
        combatVM = vm

        let combatScene = CombatScene(size: CGSize(width: 400, height: 220))
        combatScene.scaleMode = .aspectFill
        combatScene.configure(playerClass: player.playerClass, monsterIconStr: vm.monster.icon)
        scene = combatScene
    }

    // MARK: - Header

    private func combatHeader(combatVM: CombatViewModel) -> some View {
        HStack(spacing: 12) {
            // Joueur
            VStack(alignment: .leading, spacing: 4) {
                if let player = gameVM.player {
                    Text(player.name)
                        .font(Theme.captionFont.bold())
                        .foregroundStyle(Theme.textPrimary)
                    HealthBar(current: player.currentHP, maximum: player.totalMaxHP, barColor: Theme.healthBar, height: 10)
                    HealthBar(current: player.currentMana, maximum: player.maxMana, barColor: Theme.manaBar, height: 8, showText: false)
                }
            }
            .frame(maxWidth: .infinity)

            // VS
            Text("Tour \(combatVM.turnCount)")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.accent)
                .padding(.horizontal, 8)

            // Monstre
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Text(combatVM.monster.icon)
                    Text(combatVM.monster.name)
                        .font(Theme.captionFont.bold())
                        .foregroundStyle(Theme.primary)
                }
                HealthBar(current: combatVM.monster.currentHP, maximum: combatVM.monster.maxHP, barColor: Theme.primary, height: 10)
                Text("Niv. \(combatVM.monster.level)")
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(Theme.smallPadding)
        .background(Theme.backgroundLight)
    }

    // MARK: - Log

    private func combatLogView(combatVM: CombatViewModel) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(Array(combatVM.combatLog.enumerated()), id: \.offset) { index, message in
                    Text(message)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(index == 0 ? Theme.textPrimary : Theme.textSecondary.opacity(0.7))
                }
            }
            .padding(Theme.smallPadding)
        }
        .frame(height: 100)
        .background(Theme.backgroundLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
        .padding(.horizontal, Theme.smallPadding)
    }

    // MARK: - Boutons d'action

    private func actionButtons(combatVM: CombatViewModel) -> some View {
        VStack(spacing: 8) {
            // Attaque basique
            Button { combatVM.playerAttack() } label: {
                HStack {
                    Text("⚔️")
                    Text("Attaquer")
                }
                .frame(maxWidth: .infinity)
                .darkFantasyButton()
            }

            // Skills
            HStack(spacing: 8) {
                ForEach(combatVM.playerSkills, id: \.id) { skill in
                    Button {
                        combatVM.playerUseSkill(skill)
                        if skill.isHeal { scene?.animateHeal() }
                    } label: {
                        VStack(spacing: 2) {
                            Text(skill.name)
                                .font(.system(size: 10, weight: .bold))
                            Text("\(skill.manaCost) MP")
                                .font(.system(size: 9))
                        }
                        .foregroundStyle(combatVM.canAffordSkill(skill) ? Theme.textPrimary : Theme.textSecondary.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(combatVM.canAffordSkill(skill) ? Theme.secondary.opacity(0.3) : Theme.backgroundLight)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
                    }
                    .disabled(!combatVM.canAffordSkill(skill))
                }
            }

            // Potion
            if !combatVM.potions.isEmpty {
                Button { combatVM.showPotionPicker = true } label: {
                    HStack {
                        Text("🧪")
                        Text("Potion (\(combatVM.potions.count))")
                    }
                    .frame(maxWidth: .infinity)
                    .secondaryButton()
                }
            }
        }
        .padding(Theme.smallPadding)
    }

    // MARK: - Victoire / Defaite

    private func victoryButtons() -> some View {
        Button {
            let rewards = combatVM?.generateRewards()
            if let rewards {
                gameVM.onCombatVictory(rewards: rewards)
            }
            showRewards = true
        } label: {
            HStack {
                Text("🏆")
                Text("Victoire !")
            }
            .frame(maxWidth: .infinity)
            .darkFantasyButton()
        }
        .padding(Theme.smallPadding)
    }

    private func defeatButton() -> some View {
        Button {
            gameVM.onCombatDefeat()
        } label: {
            HStack {
                Text("💀")
                Text("Defaite...")
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.backgroundLight)
            .foregroundStyle(Theme.textSecondary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
        }
        .padding(Theme.smallPadding)
    }

    // MARK: - Sheets

    private func potionPicker() -> some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Utiliser une potion")
                    .font(Theme.headingFont)
                    .foregroundStyle(Theme.textPrimary)
                    .padding(.top, 20)

                ForEach(combatVM?.potions ?? [], id: \.id) { potion in
                    Button {
                        combatVM?.playerUsePotion(potion)
                        scene?.animateHeal()
                    } label: {
                        HStack {
                            Text(potion.icon)
                            Text(potion.name)
                                .font(Theme.bodyFont)
                            Spacer()
                            Text("+\(potion.healAmount)")
                                .font(Theme.statFont)
                                .foregroundStyle(Theme.assassinColor)
                        }
                        .foregroundStyle(Theme.textPrimary)
                        .padding(12)
                        .background(Theme.backgroundLight)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
                    }
                }
                Spacer()
            }
            .padding(.horizontal, Theme.padding)
        }
    }

    private func rewardsSheet() -> some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("🏆").font(.system(size: 50))
                Text("Victoire !").font(Theme.headingFont).foregroundStyle(Theme.accent)

                if let rewards = gameVM.lastCombatRewards {
                    VStack(spacing: 12) {
                        HStack {
                            Text("XP gagne:")
                                .foregroundStyle(Theme.textSecondary)
                            Spacer()
                            Text("+\(rewards.xpGained)")
                                .font(Theme.statFont)
                                .foregroundStyle(Theme.xpBar)
                        }
                        HStack {
                            Text("Or gagne:")
                                .foregroundStyle(Theme.textSecondary)
                            Spacer()
                            Text("+\(rewards.goldGained) 🪙")
                                .font(Theme.statFont)
                                .foregroundStyle(Theme.accent)
                        }
                        if !rewards.itemsLooted.isEmpty {
                            Divider().background(Theme.border)
                            Text("Butin:").foregroundStyle(Theme.textSecondary)
                            ForEach(rewards.itemsLooted) { item in
                                HStack {
                                    Text(item.icon)
                                    Text(item.name)
                                        .foregroundStyle(Theme.textPrimary)
                                    Spacer()
                                    Text(item.rarity.rawValue)
                                        .font(Theme.captionFont)
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                        }
                    }
                    .font(Theme.bodyFont)
                    .darkFantasyPanel()
                }

                if gameVM.showLevelUpAlert {
                    Text("NIVEAU SUPERIEUR !")
                        .font(Theme.headingFont)
                        .foregroundStyle(Theme.accent)
                        .padding(.top, 8)
                }

                Spacer()

                Button {
                    showRewards = false
                    gameVM.showLevelUpAlert = false
                    gameVM.returnToMap()
                } label: {
                    Text("Continuer")
                        .frame(maxWidth: .infinity)
                        .darkFantasyButton()
                }
                .padding(.bottom, 20)
            }
            .padding(Theme.padding)
        }
    }
}

#Preview {
    CombatView()
        .environment(GameViewModel())
}
