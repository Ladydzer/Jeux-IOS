// HealthBar.swift
// ShadowQuest
//
// Composant reutilisable — barre de vie animee

import SwiftUI

struct HealthBar: View {
    var body: some View {
        // TODO: Phase 1 — Implementer la barre de vie
        // Parametres : currentHP, maxHP, barColor
        // Animation fluide quand HP change
        RoundedRectangle(cornerRadius: 4)
            .fill(.red)
            .frame(height: 12)
    }
}

#Preview {
    HealthBar()
}
