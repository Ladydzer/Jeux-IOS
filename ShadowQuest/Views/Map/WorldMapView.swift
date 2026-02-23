// WorldMapView.swift
// ShadowQuest
//
// Carte du monde — placeholder Phase 1, implementee Phase 2

import SwiftUI

struct WorldMapView: View {
    @Environment(GameViewModel.self) private var gameVM

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header avec info joueur
                if let player = gameVM.player {
                    playerHeader(player: player)
                }

                Spacer()

                // Placeholder carte
                VStack(spacing: 16) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Theme.secondary.opacity(0.5))

                    Text("Carte du Monde")
                        .font(Theme.headingFont)
                        .foregroundStyle(Theme.textPrimary)

                    Text("Bientot disponible — Phase 2")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                }

                Spacer()

                // Bouton sauvegarder
                Button {
                    gameVM.saveGame()
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                        Text("Sauvegarder")
                    }
                    .secondaryButton()
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, Theme.padding)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    gameVM.saveGame()
                    gameVM.navigationPath = []
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Menu")
                    }
                    .foregroundStyle(Theme.textSecondary)
                }
            }
        }
    }

    private func playerHeader(player: Player) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.name)
                        .font(Theme.headingFont)
                        .foregroundStyle(Theme.textPrimary)

                    Text("\(player.playerClass.rawValue) — Niv. \(player.level)")
                        .font(Theme.captionFont)
                        .foregroundStyle(Color.forPlayerClass(player.playerClass))
                }

                Spacer()

                // Or
                HStack(spacing: 4) {
                    Text("🪙")
                    Text("\(player.gold)")
                        .font(Theme.statFont)
                        .foregroundStyle(Theme.accent)
                }
            }

            // Barres HP / Mana / XP
            VStack(spacing: 6) {
                HealthBar(current: player.currentHP, maximum: player.maxHP, barColor: Theme.healthBar)
                HealthBar(current: player.currentMana, maximum: player.maxMana, barColor: Theme.manaBar)
                HealthBar(
                    current: player.xp,
                    maximum: player.xpToNextLevel,
                    barColor: Theme.xpBar,
                    height: Theme.smallBarHeight,
                    showText: false
                )
            }
        }
        .darkFantasyPanel()
    }
}

#Preview {
    let vm = GameViewModel()
    NavigationStack {
        WorldMapView()
    }
    .environment(vm)
}
