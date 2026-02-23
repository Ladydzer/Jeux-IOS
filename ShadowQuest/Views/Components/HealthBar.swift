// HealthBar.swift
// ShadowQuest
//
// Composant reutilisable — barre de vie/mana/XP animee

import SwiftUI

struct HealthBar: View {
    let current: Int
    let maximum: Int
    var barColor: Color = Theme.healthBar
    var height: CGFloat = Theme.barHeight
    var showText: Bool = true

    private var percent: Double {
        guard maximum > 0 else { return 0 }
        return Double(current) / Double(maximum)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Fond
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.black.opacity(0.6))

                // Barre
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(barColor)
                    .frame(width: max(0, geo.size.width * percent))
                    .animation(.easeInOut(duration: 0.4), value: percent)

                // Texte
                if showText {
                    Text("\(current)/\(maximum)")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textPrimary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 16) {
        HealthBar(current: 80, maximum: 120, barColor: Theme.healthBar)
        HealthBar(current: 30, maximum: 100, barColor: Theme.manaBar)
        HealthBar(current: 50, maximum: 100, barColor: Theme.xpBar, height: Theme.smallBarHeight, showText: false)
    }
    .padding()
    .background(Theme.background)
}
