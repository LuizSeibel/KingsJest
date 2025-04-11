//
//  Plataform.swift
//  KingsJest
//
//  Created by Willys Oliveira on 02/04/25.
//

import SpriteKit

class Plataform {
    var nodes: [SKSpriteNode] = []
    
    init (scene: SKScene) {
        
        for node in scene.children {
            if node.name == "plataforma" || node.name == "plataformaInclinada" || node.name == "blocoArmadilha" || node.name == "plataformaDinamica" {
                if let plataformNode = node as? SKSpriteNode {
                    setupPhysics(for: plataformNode)
                    nodes.append(plataformNode)
                }
            }
        }
    }
    
    private func setupPhysics(for plataformNode: SKSpriteNode) {
        plataformNode.physicsBody = SKPhysicsBody(texture: plataformNode.texture!, size: plataformNode.size)
        plataformNode.physicsBody?.isDynamic = false
        plataformNode.physicsBody?.restitution = 0
        plataformNode.physicsBody?.friction = 0
        plataformNode.physicsBody?.categoryBitMask = .plataform
        plataformNode.physicsBody?.contactTestBitMask = .player
        plataformNode.physicsBody?.collisionBitMask = .player
    }
    
    func startDynamicPlatformsMovement() {
        for node in nodes {
            guard node.name == "plataformaDinamica" else { continue }

            // Distância total de ida e volta no eixo X
            let moveDistance: CGFloat = 150
            let moveDuration: TimeInterval = 2.0

            // Ações de movimento
            let moveRight = SKAction.moveBy(x: moveDistance, y: 0, duration: moveDuration)
            let moveLeft = SKAction.moveBy(x: -moveDistance, y: 0, duration: moveDuration)
            let sequence = SKAction.sequence([moveRight, moveLeft])

            // Repetição infinita
            let repeatForever = SKAction.repeatForever(sequence)

            node.run(repeatForever, withKey: "dynamicMovement")
        }
    }
}
