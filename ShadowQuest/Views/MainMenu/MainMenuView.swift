// MainMenuView.swift
// ShadowQuest
//
// Ecran du menu principal — dark fantasy

import SwiftUI

struct MainMenuView: View {
    @Environment(GameViewModel.self) private var gameVM

    @State private var titleOpacity = 0.0
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity = 0.0
    @State private var flickerOpacity = 0.7

    var body: some View {
        ZStack {
            // Fond
            Theme.background
                .ignoresSafeArea()

            // Particules decoratives
            backgroundParticles

            VStack(spacing: 0) {
                Spacer()

                // Titre
                titleSection

                Spacer()

                // Boutons
                buttonsSection

                Spacer()

                // Credits
                Text("v0.1 — Phase 1")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary.opacity(0.5))
                    .padding(.bottom, 20)
            }
        }
        .onAppear {
            animateEntrance()
        }
    }

    // MARK: - Titre

    private var titleSection: some View {
        VStack(spacing: 8) {
            Text("Shadow")
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)
            +
            Text("Quest")
                .font(Theme.titleFont)
                .foregroundStyle(Theme.primary)

            Text("Dark Fantasy RPG")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
                .tracking(4)
                .textCase(.uppercase)
        }
        .opacity(titleOpacity)
    }

    // MARK: - Boutons

    private var buttonsSection: some View {
        VStack(spacing: 16) {
            // Nouvelle Partie
            Button {
                gameVM.navigateTo(.characterCreation)
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Nouvelle Partie")
                }
                .frame(maxWidth: 260)
                .darkFantasyButton()
            }

            // Continuer (si sauvegarde existante)
            if gameVM.showContinueButton {
                Button {
                    gameVM.continueGame()
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Continuer")
                    }
                    .frame(maxWidth: 260)
                    .secondaryButton()
                }
            }
        }
        .offset(y: buttonsOffset)
        .opacity(buttonsOpacity)
    }

    // MARK: - Particules de fond

    private var backgroundParticles: some View {
        Canvas { context, size in
            for i in 0..<30 {
                let x = Double(i) / 30.0 * size.width
                let y = Double((i * 7 + 13) % 30) / 30.0 * size.height
                let radius = CGFloat((i % 3) + 1)

                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: radius, height: radius)),
                    with: .color(Theme.primary.opacity(0.15))
                )
            }
        }
        .opacity(flickerOpacity)
        .ignoresSafeArea()
    }

    // MARK: - Animation

    private func animateEntrance() {
        withAnimation(.easeOut(duration: 1.2)) {
            titleOpacity = 1.0
        }
        withAnimation(.easeOut(duration: 0.8).delay(0.5)) {
            buttonsOffset = 0
            buttonsOpacity = 1.0
        }
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            flickerOpacity = 1.0
        }
    }
}

#Preview {
    MainMenuView()
        .environment(GameViewModel())
}
