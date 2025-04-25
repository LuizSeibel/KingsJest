//
//  Ground.swift
//  KingsJest
//
//  Created by Willys Oliveira on 02/04/25.
//

import SpriteKit

class Ground {
    
    var nodes: [SKSpriteNode] = []
    
    init (scene: SKScene) {
        
        for node in scene.children {
            if node.name == "delimitacao" {
                if let delimitacaoNode = node as? SKSpriteNode {
                    setupPhysics(for: delimitacaoNode)
                    nodes.append(delimitacaoNode)
                }
            }
        }
    }
    
    private func setupPhysics(for delimitacaoNode: SKSpriteNode) {
        delimitacaoNode.physicsBody = SKPhysicsBody(rectangleOf: delimitacaoNode.size)
        delimitacaoNode.physicsBody?.isDynamic = false
        delimitacaoNode.physicsBody?.restitution = 0
        delimitacaoNode.physicsBody?.friction = 0
        delimitacaoNode.physicsBody?.categoryBitMask = .ground
        delimitacaoNode.physicsBody?.contactTestBitMask = 0
        delimitacaoNode.physicsBody?.collisionBitMask = .player
    }

}
