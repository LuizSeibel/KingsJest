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
            if node.name == "plataforma" || node.name == "plataformaInclinada" || node.name == "blocoArmadilha" || node.name == "plataformaDinamicaHorizontal" || node.name == "plataformaDinamicaVertical" {
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
    
    func startHorizontalPlatformsMovement() {
        for node in nodes {
            guard node.name == "plataformaDinamicaHorizontal" else { continue }

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
    
    func startVerticalPlatformsMovement() {
        for node in nodes {
            guard node.name == "plataformaDinamicaVertical" else { continue }

            // Configuração de deslocamento vertical
            let moveDistance: CGFloat = 110
            let moveDuration: TimeInterval = 2.0

            let moveDown = SKAction.moveBy(x: 0, y: -moveDistance, duration: moveDuration)
            let moveUp = SKAction.moveBy(x: 0, y: moveDistance, duration: moveDuration)
            let sequence = SKAction.sequence([moveDown, moveUp])

            let repeatForever = SKAction.repeatForever(sequence)
            repeatForever.timingMode = .easeInEaseOut

            node.run(repeatForever, withKey: "dynamicVerticalMovement")
        }
    }

}
