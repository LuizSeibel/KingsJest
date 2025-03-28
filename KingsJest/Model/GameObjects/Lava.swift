//
//  Lava.swift
//  KingsJest
//
//  Created by Willys Oliveira on 28/03/25.
//

import SpriteKit

class Lava {
    
    var nodes: [SKSpriteNode] = []
    
    init(scene: SKScene) {
        for node in scene.children where node.name == "cena2Lava" {
            if let lavaNode = node as? SKSpriteNode {
                setupPhysics(for: lavaNode)
                nodes.append(lavaNode)
            }
        }
    }
    
    private func setupPhysics(for lavaNode: SKSpriteNode) {
        lavaNode.physicsBody = SKPhysicsBody(texture: lavaNode.texture!, size: lavaNode.size)
        lavaNode.physicsBody?.isDynamic = false
        lavaNode.physicsBody?.categoryBitMask = 2
        lavaNode.physicsBody?.contactTestBitMask = 1
        lavaNode.physicsBody?.collisionBitMask = 0
    }
}
