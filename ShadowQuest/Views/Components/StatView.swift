// StatView.swift
// ShadowQuest
//
// Composant reutilisable — affichage d'une statistique

import SwiftUI

struct StatView: View {
    let icon: String
    let label: String
    let value: Int
    var color: Color = Theme.textPrimary

    var body: some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 14))

            Text(label)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)

            Spacer()

            Text("\(value)")
                .font(Theme.statFont)
                .foregroundStyle(color)
        }
    }
}

struct StatRow: View {
    let player: Player

    var body: some View {
        VStack(spacing: 8) {
            StatView(icon: "⚔️", label: "ATK", value: player.attack, color: Theme.primary)
            StatView(icon: "🛡️", label: "DEF", value: player.defense, color: Theme.secondary)
            StatView(icon: "💨", label: "SPD", value: player.speed, color: Theme.assassinColor)
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        StatView(icon: "⚔️", label: "ATK", value: 15, color: Theme.primary)
        StatView(icon: "🛡️", label: "DEF", value: 12, color: Theme.secondary)
        StatView(icon: "💨", label: "SPD", value: 8, color: Theme.assassinColor)
    }
    .padding()
    .background(Theme.background)
}
