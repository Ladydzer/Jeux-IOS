// Theme.swift
// ShadowQuest
//
// Theme visuel — couleurs, polices, dimensions

import SwiftUI

enum Theme {
    // Couleurs principales
    static let background = Color(red: 0.08, green: 0.06, blue: 0.1)   // Noir profond violet
    static let backgroundLight = Color(red: 0.14, green: 0.11, blue: 0.18) // Panneau sombre
    static let primary = Color(red: 0.8, green: 0.15, blue: 0.15)      // Rouge sang
    static let secondary = Color(red: 0.55, green: 0.4, blue: 0.8)     // Violet mystique
    static let accent = Color(red: 0.95, green: 0.75, blue: 0.2)       // Or
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.6)
    static let border = Color(white: 0.25)

    // Couleurs de rarete
    static let rarityCommon = Color(white: 0.7)
    static let rarityUncommon = Color(red: 0.2, green: 0.8, blue: 0.3)
    static let rarityRare = Color(red: 0.3, green: 0.5, blue: 1.0)
    static let rarityEpic = Color(red: 0.7, green: 0.3, blue: 0.9)
    static let rarityLegendary = Color(red: 1.0, green: 0.6, blue: 0.0)

    // Couleurs de classes
    static let warriorColor = Color(red: 0.9, green: 0.3, blue: 0.2)
    static let mageColor = Color(red: 0.3, green: 0.4, blue: 0.95)
    static let assassinColor = Color(red: 0.3, green: 0.85, blue: 0.4)

    // Couleurs de barres
    static let healthBar = Color(red: 0.8, green: 0.15, blue: 0.15)
    static let manaBar = Color(red: 0.2, green: 0.4, blue: 0.9)
    static let xpBar = Color(red: 0.95, green: 0.75, blue: 0.2)

    // Polices
    static let titleFont = Font.system(size: 42, weight: .black, design: .serif)
    static let headingFont = Font.system(size: 24, weight: .bold, design: .serif)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 12, weight: .medium, design: .default)
    static let statFont = Font.system(size: 14, weight: .bold, design: .monospaced)

    // Dimensions
    static let cornerRadius: CGFloat = 12
    static let smallCornerRadius: CGFloat = 6
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let barHeight: CGFloat = 14
    static let smallBarHeight: CGFloat = 8
}
