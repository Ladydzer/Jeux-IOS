// InventoryView.swift
// ShadowQuest
//
// Ecran d'inventaire du joueur

import SwiftUI

struct InventoryView: View {
    @Environment(GameViewModel.self) private var gameVM
    @State private var invVM = InventoryViewModel()

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if let player = gameVM.player {
                VStack(spacing: 12) {
                    equipmentSection(player: player)
                    tabBar

                    ScrollView {
                        if invVM.filteredInventory(for: player).isEmpty {
                            VStack(spacing: 12) {
                                Text("🎒").font(.system(size: 40))
                                Text("Inventaire vide")
                                    .font(Theme.captionFont)
                                    .foregroundStyle(Theme.textSecondary)
                            }
                            .padding(.top, 40)
                        } else {
                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(invVM.filteredInventory(for: player)) { item in
                                    ItemCard(item: item,
                                        isEquipped: player.equippedWeapon?.id == item.id || player.equippedArmor?.id == item.id
                                    ) { invVM.selectItem(item) }
                                }
                            }
                            .padding(.horizontal, Theme.padding)
                        }
                    }

                    HStack {
                        Text("🪙")
                        Text("\(player.gold) Or")
                            .font(Theme.statFont)
                            .foregroundStyle(Theme.accent)
                        Spacer()
                        Text("\(player.inventory.count) objets")
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.horizontal, Theme.padding)
                    .padding(.bottom, 8)
                }
            }
        }
        .navigationTitle("Inventaire")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $invVM.showItemDetail) {
            if let item = invVM.selectedItem, let player = gameVM.player {
                ItemDetailSheet(item: item, player: player, invVM: invVM)
                    .presentationDetents([.medium])
            }
        }
    }

    private func equipmentSection(player: Player) -> some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("Arme").font(Theme.captionFont).foregroundStyle(Theme.textSecondary)
                if let weapon = player.equippedWeapon {
                    ItemCard(item: weapon, isEquipped: true) { invVM.selectItem(weapon) }
                } else {
                    emptySlot
                }
            }

            VStack(spacing: 4) {
                StatView(icon: "⚔️", label: "ATK", value: player.totalAttack, color: Theme.primary)
                StatView(icon: "🛡️", label: "DEF", value: player.totalDefense, color: Theme.secondary)
                StatView(icon: "💨", label: "SPD", value: player.totalSpeed, color: Theme.assassinColor)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 4) {
                Text("Armure").font(Theme.captionFont).foregroundStyle(Theme.textSecondary)
                if let armor = player.equippedArmor {
                    ItemCard(item: armor, isEquipped: true) { invVM.selectItem(armor) }
                } else {
                    emptySlot
                }
            }
        }
        .padding(Theme.smallPadding)
        .background(Theme.backgroundLight.opacity(0.5))
    }

    private var emptySlot: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Theme.border, style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(width: 60, height: 60)
                .overlay(Text("—").foregroundStyle(Theme.textSecondary))
            Text("Aucun")
                .font(.system(size: 9))
                .foregroundStyle(Theme.textSecondary)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(InventoryTab.allCases, id: \.self) { tab in
                Button {
                    invVM.selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(Theme.captionFont)
                        .foregroundStyle(invVM.selectedTab == tab ? Theme.textPrimary : Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(invVM.selectedTab == tab ? Theme.primary.opacity(0.3) : Color.clear)
                }
            }
        }
        .background(Theme.backgroundLight)
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
        .padding(.horizontal, Theme.padding)
    }
}

// MARK: - Detail d'un item

struct ItemDetailSheet: View {
    let item: Item
    let player: Player
    @Bindable var invVM: InventoryViewModel

    private var rarityColor: Color {
        switch item.rarity {
        case .common: return Theme.rarityCommon
        case .uncommon: return Theme.rarityUncommon
        case .rare: return Theme.rarityRare
        case .epic: return Theme.rarityEpic
        case .legendary: return Theme.rarityLegendary
        }
    }

    private var isEquipped: Bool {
        player.equippedWeapon?.id == item.id || player.equippedArmor?.id == item.id
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 16) {
                Text(item.icon).font(.system(size: 50))
                Text(item.name).font(Theme.headingFont).foregroundStyle(Theme.textPrimary)
                Text(item.rarity.rawValue).font(Theme.captionFont).foregroundStyle(rarityColor)
                Text(item.description)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                if item.type != .potion {
                    VStack(spacing: 6) {
                        if item.attackBonus != 0 { statLine("ATK", value: item.attackBonus) }
                        if item.defenseBonus != 0 { statLine("DEF", value: item.defenseBonus) }
                        if item.speedBonus != 0 { statLine("SPD", value: item.speedBonus) }
                        if item.hpBonus != 0 { statLine("PV", value: item.hpBonus) }
                    }
                    .darkFantasyPanel()
                }

                Spacer()

                HStack(spacing: 12) {
                    if item.type == .potion {
                        Button { invVM.usePotion(item, player: player) } label: {
                            Text("Utiliser").frame(maxWidth: .infinity).darkFantasyButton()
                        }
                    } else if isEquipped {
                        Button {
                            if item.type == .weapon { player.unequipWeapon() }
                            else { player.unequipArmor() }
                            invVM.showItemDetail = false
                        } label: {
                            Text("Retirer").frame(maxWidth: .infinity).secondaryButton()
                        }
                    } else {
                        Button { invVM.equipItem(item, player: player) } label: {
                            Text("Equiper").frame(maxWidth: .infinity).darkFantasyButton()
                        }
                    }

                    Button { invVM.sellItem(item, player: player) } label: {
                        Text("Vendre (\(item.price / 2)🪙)")
                            .frame(maxWidth: .infinity).secondaryButton()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.top, 20)
        }
    }

    private func statLine(_ label: String, value: Int) -> some View {
        HStack {
            Text(label).font(Theme.captionFont).foregroundStyle(Theme.textSecondary)
            Spacer()
            Text(value > 0 ? "+\(value)" : "\(value)")
                .font(Theme.statFont)
                .foregroundStyle(value > 0 ? Theme.assassinColor : Theme.primary)
        }
    }
}

// MARK: - Marchand

struct MerchantView: View {
    @Environment(GameViewModel.self) private var gameVM
    let zone: Zone
    @State private var invVM = InventoryViewModel()
    @State private var purchaseMessage: String?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            if let player = gameVM.player {
                VStack(spacing: 16) {
                    Text("🪙").font(.system(size: 40))
                    Text("Marchand").font(Theme.headingFont).foregroundStyle(Theme.textPrimary)
                    HStack {
                        Text("Ton or:").foregroundStyle(Theme.textSecondary)
                        Text("\(player.gold) 🪙").font(Theme.statFont).foregroundStyle(Theme.accent)
                    }

                    if let msg = purchaseMessage {
                        Text(msg).font(Theme.captionFont).foregroundStyle(Theme.assassinColor)
                    }

                    ScrollView {
                        ForEach(ItemCatalog.merchantItems(for: zone)) { item in
                            merchantRow(item: item, player: player)
                        }
                    }
                    .padding(.horizontal, Theme.padding)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle("Marchand")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func merchantRow(item: Item, player: Player) -> some View {
        HStack(spacing: 12) {
            Text(item.icon).font(.system(size: 24))
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name).font(Theme.bodyFont).foregroundStyle(Theme.textPrimary)
                Text(item.description).font(.system(size: 10)).foregroundStyle(Theme.textSecondary).lineLimit(1)
            }
            Spacer()
            Button {
                if invVM.buyItem(item, player: player) {
                    purchaseMessage = "\(item.name) achete !"
                } else {
                    purchaseMessage = "Pas assez d'or !"
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { purchaseMessage = nil }
            } label: {
                Text("\(item.price)🪙")
                    .font(Theme.captionFont.bold())
                    .foregroundStyle(player.gold >= item.price ? Theme.accent : Theme.textSecondary.opacity(0.4))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .background(Theme.backgroundLight)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .disabled(player.gold < item.price)
        }
        .padding(10)
        .background(Theme.backgroundLight.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
    }
}

#Preview {
    NavigationStack {
        InventoryView()
    }
    .environment(GameViewModel())
}
