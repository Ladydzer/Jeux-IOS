// ItemCard.swift
// ShadowQuest
//
// Composant reutilisable — carte d'objet dans l'inventaire

import SwiftUI

struct ItemCard: View {
    var body: some View {
        // TODO: Phase 4 — Implementer la carte d'item
        // Parametres : item (Item model)
        // Affichage : icone, nom, rarete (couleur du bord), stats
        RoundedRectangle(cornerRadius: 8)
            .fill(.gray.opacity(0.2))
            .frame(width: 80, height: 80)
    }
}

#Preview {
    ItemCard()
}
