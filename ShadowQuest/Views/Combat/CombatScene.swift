// CombatScene.swift
// ShadowQuest
//
// Scene SpriteKit pour le rendu visuel des combats

import SpriteKit

class CombatScene: SKScene {
    private var playerNode: SKShapeNode!
    private var monsterNode: SKShapeNode!
    private var playerClassType: PlayerClass = .warrior
    private var monsterIcon: String = "👺"

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(red: 0.08, green: 0.06, blue: 0.1, alpha: 1)
        setupBackground()
        setupPlayer()
        setupMonster()
    }

    func configure(playerClass: PlayerClass, monsterIconStr: String) {
        self.playerClassType = playerClass
        self.monsterIcon = monsterIconStr
    }

    private func setupBackground() {
        let ground = SKShapeNode(rectOf: CGSize(width: size.width, height: 80))
        ground.position = CGPoint(x: size.width / 2, y: 40)
        ground.fillColor = UIColor(red: 0.12, green: 0.1, blue: 0.16, alpha: 1)
        ground.strokeColor = UIColor(red: 0.2, green: 0.18, blue: 0.25, alpha: 1)
        addChild(ground)

        for _ in 0..<15 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
            particle.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
            particle.fillColor = UIColor(red: 0.8, green: 0.15, blue: 0.15, alpha: 0.2)
            particle.strokeColor = .clear
            addChild(particle)
            let fade = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.05, duration: Double.random(in: 2...4)),
                SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 2...4))
            ])
            particle.run(SKAction.repeatForever(fade))
        }
    }

    private func setupPlayer() {
        let color: UIColor = switch playerClassType {
        case .warrior: UIColor(red: 0.9, green: 0.3, blue: 0.2, alpha: 1)
        case .mage: UIColor(red: 0.3, green: 0.4, blue: 0.95, alpha: 1)
        case .assassin: UIColor(red: 0.3, green: 0.85, blue: 0.4, alpha: 1)
        }

        playerNode = SKShapeNode(rectOf: CGSize(width: 50, height: 70), cornerRadius: 8)
        playerNode.position = CGPoint(x: size.width * 0.25, y: 120)
        playerNode.fillColor = color
        playerNode.strokeColor = color.withAlphaComponent(0.6)
        playerNode.lineWidth = 2
        addChild(playerNode)

        let icon: String = switch playerClassType {
        case .warrior: "🗡️"
        case .mage: "🔮"
        case .assassin: "🗡️"
        }
        let label = SKLabelNode(text: icon)
        label.fontSize = 30
        label.position = CGPoint(x: 0, y: -10)
        playerNode.addChild(label)

        let idle = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 1),
            SKAction.moveBy(x: 0, y: -5, duration: 1)
        ])
        playerNode.run(SKAction.repeatForever(idle))
    }

    private func setupMonster() {
        monsterNode = SKShapeNode(rectOf: CGSize(width: 60, height: 60), cornerRadius: 12)
        monsterNode.position = CGPoint(x: size.width * 0.75, y: 120)
        monsterNode.fillColor = UIColor(red: 0.4, green: 0.1, blue: 0.1, alpha: 1)
        monsterNode.strokeColor = UIColor(red: 0.8, green: 0.15, blue: 0.15, alpha: 0.5)
        monsterNode.lineWidth = 2
        addChild(monsterNode)

        let label = SKLabelNode(text: monsterIcon)
        label.fontSize = 35
        label.position = CGPoint(x: 0, y: -12)
        monsterNode.addChild(label)

        let idle = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -4, duration: 0.8),
            SKAction.moveBy(x: 0, y: 4, duration: 0.8)
        ])
        monsterNode.run(SKAction.repeatForever(idle))
    }

    // MARK: - Animations publiques

    func animatePlayerAttack() {
        guard let playerNode, let monsterNode else { return }
        let originalPos = playerNode.position
        let attack = SKAction.sequence([
            SKAction.moveTo(x: monsterNode.position.x - 40, duration: 0.15),
            SKAction.run { [weak self] in
                self?.flashNode(self?.monsterNode)
                self?.showDamageParticles(at: monsterNode.position)
            },
            SKAction.moveTo(x: originalPos.x, duration: 0.2)
        ])
        playerNode.run(attack)
    }

    func animateMonsterAttack() {
        guard let playerNode, let monsterNode else { return }
        let originalPos = monsterNode.position
        let attack = SKAction.sequence([
            SKAction.moveTo(x: playerNode.position.x + 40, duration: 0.15),
            SKAction.run { [weak self] in
                self?.flashNode(self?.playerNode)
                self?.showDamageParticles(at: playerNode.position)
            },
            SKAction.moveTo(x: originalPos.x, duration: 0.2)
        ])
        monsterNode.run(attack)
    }

    func animateHeal() {
        guard let playerNode else { return }
        showHealParticles(at: playerNode.position)
    }

    func animateMonsterDeath() {
        guard let monsterNode else { return }
        let death = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.5),
                SKAction.scale(to: 0.1, duration: 0.5),
                SKAction.rotate(byAngle: .pi, duration: 0.5)
            ]),
            SKAction.removeFromParent()
        ])
        monsterNode.run(death)
    }

    private func flashNode(_ node: SKShapeNode?) {
        guard let node else { return }
        let original = node.fillColor
        let flash = SKAction.sequence([
            SKAction.run { node.fillColor = .white },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { node.fillColor = original }
        ])
        node.run(SKAction.repeat(flash, count: 2))
    }

    private func showDamageParticles(at position: CGPoint) {
        for _ in 0..<8 {
            let p = SKShapeNode(circleOfRadius: 3)
            p.position = position
            p.fillColor = UIColor(red: 1, green: 0.3, blue: 0.2, alpha: 1)
            p.strokeColor = .clear
            addChild(p)
            let action = SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: CGFloat.random(in: -40...40), y: CGFloat.random(in: 10...50), duration: 0.4),
                    SKAction.fadeOut(withDuration: 0.4)
                ]),
                SKAction.removeFromParent()
            ])
            p.run(action)
        }
    }

    private func showHealParticles(at position: CGPoint) {
        for _ in 0..<10 {
            let p = SKShapeNode(circleOfRadius: 4)
            p.position = CGPoint(x: position.x + CGFloat.random(in: -20...20), y: position.y - 20)
            p.fillColor = UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1)
            p.strokeColor = .clear
            addChild(p)
            let action = SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: 0, y: 60, duration: 0.6),
                    SKAction.fadeOut(withDuration: 0.6)
                ]),
                SKAction.removeFromParent()
            ])
            p.run(action)
        }
    }
}
