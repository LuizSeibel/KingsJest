//
//  SabotageManager.swift
//  KingsJest
//
//  Created by Luiz Seibel on 26/05/25.
//

import SpriteKit

class SabotageManager: SKNode {
    
    enum SabotageType{
        case tomato
    }
    
    private var sauceOverlay: SKSpriteNode!

    func setup(size: CGSize) {
        setupSauceOverlay(size: size)
    }

    private func setupSauceOverlay(size: CGSize) {
        sauceOverlay = SKSpriteNode(color: .red, size: size)
        sauceOverlay.alpha = 0
        sauceOverlay.zPosition = 1_000
        sauceOverlay.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(sauceOverlay)
    }
    
    func run(sabotage: SabotageType){
        switch sabotage{
        case .tomato:
            tomatoSabotage()
        }
    }
}

// MARK: - Sabotage
extension SabotageManager{
    
    // MARK: Tomato
    func tomatoSabotage() {
        let tomatoCount = 5

        let sequence = (0..<tomatoCount).flatMap { _ -> [SKAction] in
            let randomX = CGFloat.random(in: -88...91)
            let randomY = CGFloat.random(in: -160...0)
            let spawnPosition = CGPoint(x: randomX, y: randomY)

            return [
                .run { [weak self] in self?.spawnTomato(at: spawnPosition) },
                .wait(forDuration: Double.random(in: 0.2...0.8))
            ]
        }

        run(.sequence(sequence), withKey: "tomatoRain")
    }
    private func spawnTomato(at targetPosition: CGPoint) {
        let spawnPosition = CGPoint(
            x: targetPosition.x + CGFloat.random(in: -50...50),
            y: targetPosition.y + CGFloat.random(in: 80...200)
        )

        let angle = CGFloat.random(in: 0.5...1.5) * .pi
        let scale = CGFloat.random(in: 1...2)
        let targetScale = 0.5 / scale

        let tomato = TomatoNode(position: spawnPosition, scale: scale, angle: angle)
        addChild(tomato)

        let move = SKAction.group([
            .move(to: targetPosition, duration: 0.5),
            .scale(to: targetScale, duration: 0.5),
            .rotate(byAngle: angle, duration: 0.5)
        ])

        let enablePhysics = SKAction.run {
            tomato.physicsBody = {
                let body = SKPhysicsBody(rectangleOf: tomato.frame.size)
                body.isDynamic = true
                body.categoryBitMask = .tomato
                body.contactTestBitMask = .player
                body.collisionBitMask = 0
                body.affectedByGravity = false
                return body
            }()
        }

        let sequence = SKAction.sequence([
            move,
            enablePhysics,
            .fadeOut(withDuration: 0.5),
            .removeFromParent()
        ])

        tomato.run(sequence)
    }
}

// MARK: - Sabotage Effects
extension SabotageManager{
    func tomatoSabotageEffect() {
        sauceOverlay.removeAllActions()
        sauceOverlay.alpha = 1
        let fadeOut = SKAction.fadeOut(withDuration: 2.0)
        sauceOverlay.run(fadeOut)
    }
}
