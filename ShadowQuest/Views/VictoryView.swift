// VictoryView.swift
// ShadowQuest
//
// Ecran de victoire finale (apres avoir battu le boss final)

import SwiftUI

struct VictoryView: View {
    @Environment(GameViewModel.self) private var gameVM

    @State private var opacity = 0.0
    @State private var starScale = 0.1

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("⭐")
                    .font(.system(size: 80))
                    .scaleEffect(starScale)

                Text("VICTOIRE !")
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.accent)

                Text("Le Seigneur des Ombres est vaincu.\nLa lumiere revient sur le monde.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                if let player = gameVM.player {
                    VStack(spacing: 8) {
                        Text("Statistiques de \(player.name)")
                            .font(Theme.bodyFont.bold())
                            .foregroundStyle(Theme.textPrimary)

                        VStack(spacing: 4) {
                            statLine("Classe", value: player.playerClass.rawValue)
                            statLine("Niveau final", value: "\(player.level)")
                            statLine("Monstres tues", value: "\(player.monstersKilled)")
                            statLine("Boss vaincus", value: "\(player.bossesKilled)")
                            statLine("Or total", value: "\(player.gold)")
                        }
                        .darkFantasyPanel()
                    }
                    .padding(.horizontal, 30)
                }

                Spacer()

                Button {
                    gameVM.deleteCurrentGame()
                } label: {
                    Text("Retour au menu")
                        .frame(maxWidth: .infinity)
                        .darkFantasyButton()
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .opacity(opacity)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 1)) {
                opacity = 1
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.3)) {
                starScale = 1.0
            }
        }
    }

    private func statLine(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(Theme.captionFont).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value).font(Theme.statFont).foregroundStyle(Theme.accent)
        }
    }
}

#Preview {
    VictoryView()
        .environment(GameViewModel())
}
