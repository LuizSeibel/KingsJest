//
//  LavaNode.swift
//  KingsJest
//
//  Created by Luiz Seibel on 09/04/25.
//

import SpriteKit

class LavaNode{
    
    var node: SKShapeNode!
    
    private var radius: CGFloat = 10
    
    var physicsBody: SKPhysicsBody {
        let pyhsicsBody = SKPhysicsBody(circleOfRadius: radius)
        pyhsicsBody.isDynamic = true
        pyhsicsBody.affectedByGravity = true
        
        pyhsicsBody.categoryBitMask = 20
        pyhsicsBody.collisionBitMask = 0
        
        return pyhsicsBody
    }
    
    var action: SKAction{
        let wait = SKAction.wait(forDuration: 3.0)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([wait, remove])
        return sequence
    }
    
    init(radius: CGFloat = 10) {
        self.radius = radius
        node = SKShapeNode(circleOfRadius: radius)
        node.fillColor = .yellow
        
        if let particle = SKEmitterNode(fileNamed: "lavaParticle") {
            node.addChild(particle)
        }
        
        node.physicsBody = physicsBody
        
        node.zPosition = 4
        node.run(action)
    }
}
