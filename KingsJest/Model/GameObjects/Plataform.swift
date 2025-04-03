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
            if node.name == "plataforma" {
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
        plataformNode.physicsBody?.contactTestBitMask = 0
        plataformNode.physicsBody?.collisionBitMask = .player
    }

}
