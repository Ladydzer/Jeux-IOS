// GameOverView.swift
// ShadowQuest
//
// Ecran de Game Over

import SwiftUI

struct GameOverView: View {
    @Environment(GameViewModel.self) private var gameVM

    @State private var opacity = 0.0
    @State private var textOffset: CGFloat = 30

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("💀")
                    .font(.system(size: 80))

                Text("GAME OVER")
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.primary)

                if let player = gameVM.player {
                    VStack(spacing: 8) {
                        Text("\(player.name) est tombe au combat")
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.textSecondary)

                        VStack(spacing: 4) {
                            statLine("Niveau atteint", value: "\(player.level)")
                            statLine("Monstres tues", value: "\(player.monstersKilled)")
                            statLine("Boss vaincus", value: "\(player.bossesKilled)")
                            statLine("Or accumule", value: "\(player.gold)")
                        }
                        .darkFantasyPanel()
                        .padding(.horizontal, 40)
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Button {
                        gameVM.continueGame()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Charger la sauvegarde")
                        }
                        .frame(maxWidth: .infinity)
                        .darkFantasyButton()
                    }

                    Button {
                        gameVM.deleteCurrentGame()
                    } label: {
                        Text("Menu principal")
                            .frame(maxWidth: .infinity)
                            .secondaryButton()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .opacity(opacity)
            .offset(y: textOffset)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 1)) {
                opacity = 1
                textOffset = 0
            }
        }
    }

    private func statLine(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(Theme.captionFont).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value).font(Theme.statFont).foregroundStyle(Theme.textPrimary)
        }
    }
}

#Preview {
    GameOverView()
        .environment(GameViewModel())
}
