// ItemCard.swift
// ShadowQuest
//
// Composant reutilisable — carte d'objet dans l'inventaire

import SwiftUI

struct ItemCard: View {
    let item: Item
    var isEquipped: Bool = false
    var onTap: (() -> Void)?

    private var rarityColor: Color {
        switch item.rarity {
        case .common: return Theme.rarityCommon
        case .uncommon: return Theme.rarityUncommon
        case .rare: return Theme.rarityRare
        case .epic: return Theme.rarityEpic
        case .legendary: return Theme.rarityLegendary
        }
    }

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.backgroundLight)
                        .frame(width: 60, height: 60)

                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isEquipped ? Theme.accent : rarityColor.opacity(0.6), lineWidth: isEquipped ? 2 : 1)
                        .frame(width: 60, height: 60)

                    Text(item.icon)
                        .font(.system(size: 28))

                    if isEquipped {
                        VStack {
                            HStack {
                                Spacer()
                                Text("E")
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundStyle(Theme.background)
                                    .padding(3)
                                    .background(Theme.accent)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        .frame(width: 60, height: 60)
                    }
                }

                Text(item.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(rarityColor)
                    .lineLimit(1)
                    .frame(width: 65)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        ItemCard(item: ItemCatalog.ironSword)
        ItemCard(item: ItemCatalog.steelSword, isEquipped: true)
        ItemCard(item: ItemCatalog.smallPotion)
    }
    .padding()
    .background(Theme.background)
}
