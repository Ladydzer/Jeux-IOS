// InventoryViewModel.swift
// ShadowQuest
//
// ViewModel de l'inventaire

import Foundation

enum InventoryTab: String, CaseIterable {
    case all = "Tout"
    case weapons = "Armes"
    case armors = "Armures"
    case potions = "Potions"
}

@Observable
final class InventoryViewModel {
    var selectedTab: InventoryTab = .all
    var selectedItem: Item?
    var showItemDetail: Bool = false
    var isMerchantMode: Bool = false
    var merchantItems: [Item] = []

    func filteredInventory(for player: Player) -> [Item] {
        let items = player.inventory
        switch selectedTab {
        case .all: return items
        case .weapons: return items.filter { $0.type == .weapon }
        case .armors: return items.filter { $0.type == .armor }
        case .potions: return items.filter { $0.type == .potion }
        }
    }

    func selectItem(_ item: Item) {
        selectedItem = item
        showItemDetail = true
    }

    func equipItem(_ item: Item, player: Player) {
        player.equip(item)
        showItemDetail = false
    }

    func usePotion(_ item: Item, player: Player) {
        guard item.type == .potion else { return }
        player.usePotion(item)
        showItemDetail = false
    }

    func sellItem(_ item: Item, player: Player) {
        let sellPrice = item.price / 2
        player.gold += sellPrice
        player.removeFromInventory(item)
        showItemDetail = false
    }

    func buyItem(_ item: Item, player: Player) -> Bool {
        guard player.gold >= item.price else { return false }
        player.gold -= item.price
        player.addToInventory(item)
        return true
    }

    func setupMerchant(zone: Zone) {
        isMerchantMode = true
        merchantItems = ItemCatalog.merchantItems(for: zone)
    }
}
