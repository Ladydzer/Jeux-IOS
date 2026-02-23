// MapNode.swift
// ShadowQuest
//
// Modele d'un node sur la carte du monde

import Foundation

enum NodeType: String, Codable {
    case combat
    case rest
    case merchant
    case boss
    case start
}

enum Zone: String, Codable, CaseIterable {
    case cursedForest = "Foret Maudite"
    case crypts = "Cryptes Oubliees"
    case citadel = "Citadelle des Ombres"

    var zoneColor: String {
        switch self {
        case .cursedForest: return "green"
        case .crypts: return "purple"
        case .citadel: return "red"
        }
    }

    var monsterLevelRange: ClosedRange<Int> {
        switch self {
        case .cursedForest: return 1...5
        case .crypts: return 4...8
        case .citadel: return 7...12
        }
    }

    var bossId: String {
        switch self {
        case .cursedForest: return "boss_forest_guardian"
        case .crypts: return "boss_lich_king"
        case .citadel: return "boss_shadow_lord"
        }
    }
}

struct MapNode: Identifiable, Codable {
    let id: String
    let name: String
    let type: NodeType
    let zone: Zone
    let positionX: Double
    let positionY: Double
    let connectedNodeIds: [String]

    var icon: String {
        switch type {
        case .combat: return "⚔️"
        case .rest: return "🏕️"
        case .merchant: return "🪙"
        case .boss: return "💀"
        case .start: return "🏠"
        }
    }
}

enum MapData {
    static let allNodes: [MapNode] = [
        // -- Foret Maudite (Zone 1) --
        MapNode(id: "start", name: "Village d'Eryn", type: .start, zone: .cursedForest,
                positionX: 0.5, positionY: 0.9, connectedNodeIds: ["forest_1"]),
        MapNode(id: "forest_1", name: "Lisiere Sombre", type: .combat, zone: .cursedForest,
                positionX: 0.3, positionY: 0.78, connectedNodeIds: ["forest_2", "forest_merchant"]),
        MapNode(id: "forest_merchant", name: "Marchand Errant", type: .merchant, zone: .cursedForest,
                positionX: 0.7, positionY: 0.75, connectedNodeIds: ["forest_2"]),
        MapNode(id: "forest_2", name: "Sentier des Esprits", type: .combat, zone: .cursedForest,
                positionX: 0.4, positionY: 0.65, connectedNodeIds: ["forest_rest"]),
        MapNode(id: "forest_rest", name: "Clairiere Paisible", type: .rest, zone: .cursedForest,
                positionX: 0.6, positionY: 0.55, connectedNodeIds: ["forest_boss"]),
        MapNode(id: "forest_boss", name: "Antre du Gardien", type: .boss, zone: .cursedForest,
                positionX: 0.5, positionY: 0.45, connectedNodeIds: ["crypt_1"]),

        // -- Cryptes Oubliees (Zone 2) --
        MapNode(id: "crypt_1", name: "Entree des Cryptes", type: .combat, zone: .crypts,
                positionX: 0.5, positionY: 0.38, connectedNodeIds: ["crypt_2", "crypt_merchant"]),
        MapNode(id: "crypt_merchant", name: "Contrebandier", type: .merchant, zone: .crypts,
                positionX: 0.75, positionY: 0.33, connectedNodeIds: ["crypt_3"]),
        MapNode(id: "crypt_2", name: "Salle des Ossements", type: .combat, zone: .crypts,
                positionX: 0.3, positionY: 0.3, connectedNodeIds: ["crypt_rest"]),
        MapNode(id: "crypt_rest", name: "Autel Ancien", type: .rest, zone: .crypts,
                positionX: 0.4, positionY: 0.23, connectedNodeIds: ["crypt_3"]),
        MapNode(id: "crypt_3", name: "Galerie des Ames", type: .combat, zone: .crypts,
                positionX: 0.6, positionY: 0.2, connectedNodeIds: ["crypt_boss"]),
        MapNode(id: "crypt_boss", name: "Trone du Liche", type: .boss, zone: .crypts,
                positionX: 0.5, positionY: 0.15, connectedNodeIds: ["citadel_1"]),

        // -- Citadelle des Ombres (Zone 3) --
        MapNode(id: "citadel_1", name: "Porte Brisee", type: .combat, zone: .citadel,
                positionX: 0.5, positionY: 0.1, connectedNodeIds: ["citadel_rest", "citadel_2"]),
        MapNode(id: "citadel_rest", name: "Salle du Repos", type: .rest, zone: .citadel,
                positionX: 0.25, positionY: 0.07, connectedNodeIds: ["citadel_2"]),
        MapNode(id: "citadel_2", name: "Couloir des Lames", type: .combat, zone: .citadel,
                positionX: 0.6, positionY: 0.05, connectedNodeIds: ["citadel_merchant"]),
        MapNode(id: "citadel_merchant", name: "Forgeron Damne", type: .merchant, zone: .citadel,
                positionX: 0.4, positionY: 0.03, connectedNodeIds: ["citadel_boss"]),
        MapNode(id: "citadel_boss", name: "Salle du Trone", type: .boss, zone: .citadel,
                positionX: 0.5, positionY: 0.0, connectedNodeIds: []),
    ]

    static func node(byId id: String) -> MapNode? {
        allNodes.first { $0.id == id }
    }

    static func nodes(in zone: Zone) -> [MapNode] {
        allNodes.filter { $0.zone == zone }
    }
}
