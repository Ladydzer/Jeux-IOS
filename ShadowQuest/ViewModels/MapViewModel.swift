// MapViewModel.swift
// ShadowQuest
//
// ViewModel de la carte du monde

import Foundation

@Observable
final class MapViewModel {
    var nodes: [MapNode] = MapData.allNodes
    var selectedNode: MapNode?
    var showNodeDetail: Bool = false

    func isUnlocked(_ node: MapNode, unlockedIds: [String]) -> Bool {
        unlockedIds.contains(node.id)
    }

    func isCurrent(_ node: MapNode, currentId: String) -> Bool {
        node.id == currentId
    }

    func selectNode(_ node: MapNode, gameState: GameState?) {
        guard let gameState, isUnlocked(node, unlockedIds: gameState.unlockedNodeIds) else { return }
        selectedNode = node
        showNodeDetail = true
    }

    func travelToNode(_ node: MapNode, gameState: GameState?) {
        guard let gameState else { return }
        gameState.currentNodeId = node.id
    }

    func unlockConnectedNodes(from node: MapNode, gameState: GameState?) {
        guard let gameState else { return }
        for connectedId in node.connectedNodeIds {
            if !gameState.unlockedNodeIds.contains(connectedId) {
                gameState.unlockedNodeIds.append(connectedId)
            }
        }
    }

    func completeNode(_ node: MapNode, gameState: GameState?) {
        unlockConnectedNodes(from: node, gameState: gameState)
        if node.type == .boss {
            gameState?.defeatedBossIds.append(node.zone.bossId)
        }
    }

    func nodesByZone() -> [(Zone, [MapNode])] {
        Zone.allCases.map { zone in
            (zone, nodes.filter { $0.zone == zone })
        }
    }
}
