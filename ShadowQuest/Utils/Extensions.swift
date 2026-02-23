// Extensions.swift
// ShadowQuest
//
// Extensions Swift utilitaires

import SwiftUI

// MARK: - View

extension View {
    func darkFantasyPanel() -> some View {
        self
            .padding(Theme.padding)
            .background(Theme.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .stroke(Theme.border, lineWidth: 1)
            )
    }

    func darkFantasyButton() -> some View {
        self
            .font(Theme.bodyFont.bold())
            .foregroundStyle(Theme.textPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.primary)
            .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
    }

    func secondaryButton() -> some View {
        self
            .font(Theme.bodyFont.bold())
            .foregroundStyle(Theme.textPrimary)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Theme.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.smallCornerRadius)
                    .stroke(Theme.border, lineWidth: 1)
            )
    }
}

// MARK: - Color

extension Color {
    static func forPlayerClass(_ playerClass: PlayerClass) -> Color {
        switch playerClass {
        case .warrior: return Theme.warriorColor
        case .mage: return Theme.mageColor
        case .assassin: return Theme.assassinColor
        }
    }
}
