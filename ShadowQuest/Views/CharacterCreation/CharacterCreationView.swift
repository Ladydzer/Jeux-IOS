// CharacterCreationView.swift
// ShadowQuest
//
// Ecran de creation de personnage (nom + classe)

import SwiftUI

struct CharacterCreationView: View {
    @Environment(GameViewModel.self) private var gameVM

    @State private var playerName = ""
    @State private var selectedClass: PlayerClass = .warrior
    @State private var showError = false

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Titre
                    Text("Creer ton Heros")
                        .font(Theme.headingFont)
                        .foregroundStyle(Theme.textPrimary)
                        .padding(.top, 20)

                    // Champ nom
                    nameSection

                    // Selection de classe
                    classSelectionSection

                    // Apercu des stats
                    statsPreviewSection

                    // Bouton confirmer
                    confirmButton
                }
                .padding(.horizontal, Theme.padding)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Nom

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOM DU HEROS")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
                .tracking(2)

            TextField("", text: $playerName, prompt: Text("Entrez un nom...").foregroundStyle(Theme.textSecondary.opacity(0.5)))
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.textPrimary)
                .padding(12)
                .background(Theme.backgroundLight)
                .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.smallCornerRadius)
                        .stroke(showError && playerName.trimmingCharacters(in: .whitespaces).isEmpty ? Theme.primary : Theme.border, lineWidth: 1)
                )
                .autocorrectionDisabled()
        }
    }

    // MARK: - Selection de classe

    private var classSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CLASSE")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
                .tracking(2)

            ForEach(PlayerClass.allCases, id: \.self) { playerClass in
                classCard(for: playerClass)
            }
        }
    }

    private func classCard(for playerClass: PlayerClass) -> some View {
        let isSelected = selectedClass == playerClass
        let classColor = Color.forPlayerClass(playerClass)

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedClass = playerClass
            }
        } label: {
            HStack(spacing: 16) {
                // Icone de classe
                classIcon(for: playerClass)
                    .frame(width: 48, height: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(playerClass.rawValue)
                        .font(Theme.bodyFont.bold())
                        .foregroundStyle(isSelected ? classColor : Theme.textPrimary)

                    Text(playerClass.description)
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(classColor)
                        .font(.title3)
                }
            }
            .padding(12)
            .background(isSelected ? classColor.opacity(0.1) : Theme.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(isSelected ? classColor : Theme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func classIcon(for playerClass: PlayerClass) -> some View {
        let color = Color.forPlayerClass(playerClass)
        let symbol: String = switch playerClass {
        case .warrior: "shield.fill"
        case .mage: "wand.and.stars"
        case .assassin: "bolt.fill"
        }

        return ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.2))
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(color)
        }
    }

    // MARK: - Apercu des stats

    private var statsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("STATS DE BASE")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
                .tracking(2)

            VStack(spacing: 8) {
                StatView(icon: "❤️", label: "PV", value: selectedClass.baseHP, color: Theme.healthBar)
                StatView(icon: "💎", label: "MANA", value: selectedClass.baseMana, color: Theme.manaBar)
                StatView(icon: "⚔️", label: "ATK", value: selectedClass.baseAttack, color: Theme.primary)
                StatView(icon: "🛡️", label: "DEF", value: selectedClass.baseDefense, color: Theme.secondary)
                StatView(icon: "💨", label: "SPD", value: selectedClass.baseSpeed, color: Theme.assassinColor)
            }
            .darkFantasyPanel()
        }
        .animation(.easeInOut(duration: 0.3), value: selectedClass)
    }

    // MARK: - Confirmer

    private var confirmButton: some View {
        Button {
            let trimmedName = playerName.trimmingCharacters(in: .whitespaces)
            guard !trimmedName.isEmpty else {
                showError = true
                return
            }
            gameVM.startNewGame(name: trimmedName, playerClass: selectedClass)
        } label: {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                Text("Commencer l'Aventure")
            }
            .frame(maxWidth: .infinity)
            .darkFantasyButton()
        }
        .padding(.bottom, 32)
    }
}

#Preview {
    NavigationStack {
        CharacterCreationView()
    }
    .environment(GameViewModel())
}
