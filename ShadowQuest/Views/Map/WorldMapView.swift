// WorldMapView.swift
// ShadowQuest
//
// Carte du monde avec nodes cliquables

import SwiftUI

struct WorldMapView: View {
    @Environment(GameViewModel.self) private var gameVM
    @State private var mapVM = MapViewModel()

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if let player = gameVM.player {
                    playerHeader(player: player)
                        .padding(.horizontal, Theme.padding)
                        .padding(.top, 8)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    mapContent
                        .padding(.horizontal, Theme.padding)
                        .padding(.vertical, 20)
                }

                bottomBar
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    gameVM.saveGame()
                    gameVM.navigationPath = []
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Menu")
                    }
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                }
            }
        }
        .sheet(isPresented: $mapVM.showNodeDetail) {
            if let node = mapVM.selectedNode {
                NodeDetailSheet(node: node, mapVM: mapVM, gameVM: gameVM)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private func playerHeader(player: Player) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(Theme.bodyFont.bold())
                    .foregroundStyle(Theme.textPrimary)
                Text("Niv. \(player.level) \(player.playerClass.rawValue)")
                    .font(Theme.captionFont)
                    .foregroundStyle(Color.forPlayerClass(player.playerClass))
            }
            Spacer()
            HStack(spacing: 4) {
                Text("🪙")
                Text("\(player.gold)")
                    .font(Theme.statFont)
                    .foregroundStyle(Theme.accent)
            }
        }
        .padding(12)
        .background(Theme.backgroundLight.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: Theme.smallCornerRadius))
    }

    private var mapContent: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack {
                ForEach(mapVM.nodes) { node in
                    ForEach(node.connectedNodeIds, id: \.self) { connectedId in
                        if let connected = MapData.node(byId: connectedId) {
                            connectionLine(from: node, to: connected, in: width)
                        }
                    }
                }
                ForEach(mapVM.nodes) { node in
                    let unlocked = mapVM.isUnlocked(node, unlockedIds: gameVM.gameState?.unlockedNodeIds ?? [])
                    let isCurrent = mapVM.isCurrent(node, currentId: gameVM.gameState?.currentNodeId ?? "")
                    nodeView(node: node, unlocked: unlocked, isCurrent: isCurrent)
                        .position(x: node.positionX * width, y: node.positionY * 800 + 20)
                }
            }
        }
        .frame(height: 820)
    }

    private func connectionLine(from: MapNode, to: MapNode, in width: CGFloat) -> some View {
        let fromUnlocked = mapVM.isUnlocked(from, unlockedIds: gameVM.gameState?.unlockedNodeIds ?? [])
        let toUnlocked = mapVM.isUnlocked(to, unlockedIds: gameVM.gameState?.unlockedNodeIds ?? [])
        let bothUnlocked = fromUnlocked && toUnlocked
        return Path { path in
            path.move(to: CGPoint(x: from.positionX * width, y: from.positionY * 800 + 20))
            path.addLine(to: CGPoint(x: to.positionX * width, y: to.positionY * 800 + 20))
        }
        .stroke(
            bothUnlocked ? Theme.secondary.opacity(0.6) : Theme.border.opacity(0.3),
            style: StrokeStyle(lineWidth: bothUnlocked ? 2 : 1, dash: bothUnlocked ? [] : [5, 5])
        )
    }

    private func nodeView(node: MapNode, unlocked: Bool, isCurrent: Bool) -> some View {
        Button {
            mapVM.selectNode(node, gameState: gameVM.gameState)
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(unlocked ? nodeColor(for: node) : Theme.backgroundLight)
                        .frame(width: 44, height: 44)
                    if isCurrent {
                        Circle()
                            .stroke(Theme.accent, lineWidth: 3)
                            .frame(width: 50, height: 50)
                    }
                    Text(node.icon)
                        .font(.system(size: 20))
                        .opacity(unlocked ? 1 : 0.3)
                }
                Text(node.name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(unlocked ? Theme.textPrimary : Theme.textSecondary.opacity(0.4))
                    .lineLimit(1)
                    .frame(width: 70)
            }
        }
        .disabled(!unlocked)
    }

    private func nodeColor(for node: MapNode) -> Color {
        switch node.type {
        case .combat: return Theme.primary.opacity(0.3)
        case .rest: return Color.green.opacity(0.3)
        case .merchant: return Theme.accent.opacity(0.3)
        case .boss: return Color.purple.opacity(0.4)
        case .start: return Theme.secondary.opacity(0.3)
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 20) {
            Button {
                gameVM.navigateTo(.inventory)
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "bag.fill")
                    Text("Inventaire")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            if let player = gameVM.player {
                VStack(spacing: 2) {
                    HealthBar(current: player.currentHP, maximum: player.maxHP, barColor: Theme.healthBar, height: 8, showText: false)
                        .frame(width: 120)
                    Text("PV: \(player.currentHP)/\(player.maxHP)")
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            Spacer()
            Button {
                gameVM.saveGame()
            } label: {
                VStack(spacing: 2) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Sauvegarder")
                        .font(.system(size: 10))
                }
                .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(.horizontal, Theme.padding)
        .padding(.vertical, 10)
        .background(Theme.backgroundLight)
    }
}

struct NodeDetailSheet: View {
    let node: MapNode
    @Bindable var mapVM: MapViewModel
    @Bindable var gameVM: GameViewModel

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Text(node.icon).font(.system(size: 50))
                Text(node.name)
                    .font(Theme.headingFont)
                    .foregroundStyle(Theme.textPrimary)
                Text(node.zone.rawValue)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                Text(nodeDescription)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                Spacer()
                Button {
                    mapVM.travelToNode(node, gameState: gameVM.gameState)
                    mapVM.showNodeDetail = false
                    handleNodeAction()
                } label: {
                    Text(actionLabel)
                        .frame(maxWidth: .infinity)
                        .darkFantasyButton()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .padding(.top, 30)
        }
    }

    private var nodeDescription: String {
        switch node.type {
        case .combat: return "Des creatures rodent dans cette zone. Prepare-toi au combat."
        case .rest: return "Un lieu de repos. Tes PV et ton mana seront restaures."
        case .merchant: return "Un marchand propose ses services."
        case .boss: return "Un puissant ennemi t'attend ici. Assure-toi d'etre pret."
        case .start: return "Le village ou tout a commence."
        }
    }

    private var actionLabel: String {
        switch node.type {
        case .combat, .boss: return "Combattre"
        case .rest: return "Se Reposer"
        case .merchant: return "Voir le Marchand"
        case .start: return "Visiter"
        }
    }

    private func handleNodeAction() {
        switch node.type {
        case .combat, .boss:
            gameVM.currentCombatNode = node
            gameVM.navigateTo(.combat)
        case .rest:
            gameVM.player?.fullRestore()
            mapVM.completeNode(node, gameState: gameVM.gameState)
        case .merchant:
            gameVM.navigateTo(.merchant(node.zone))
            mapVM.completeNode(node, gameState: gameVM.gameState)
        case .start:
            gameVM.player?.fullRestore()
        }
    }
}

#Preview {
    let vm = GameViewModel()
    NavigationStack {
        WorldMapView()
    }
    .environment(vm)
}
