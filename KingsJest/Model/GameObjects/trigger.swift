//
//  trigger.swift
//  KingsJest
//
//  Created by Luiz Seibel on 28/03/25.
//

import Foundation
import SpriteKit

class Trigger {
    
    var node: SKNode

    init(position: CGPoint, size: CGSize, categoryBitMask: UInt32, contactTestBitMask: UInt32, texture: SKTexture? = nil) {
        self.node = SKNode()
        self.node.position = position
        
        if texture == nil {
            let body = SKPhysicsBody(rectangleOf: size)
            configurePhysics(body: body,
                             categoryBitMask: categoryBitMask,
                             contactTestBitMask: contactTestBitMask)
            self.node.physicsBody = body
        }
        else {
            let sprite = SKSpriteNode(texture: texture)
            sprite.size = size
            sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)

            let body = SKPhysicsBody(texture: sprite.texture!, size: size)
            configurePhysics(body: body,
                             categoryBitMask: categoryBitMask,
                             contactTestBitMask: contactTestBitMask)

            sprite.physicsBody = body
            self.node.addChild(sprite)
        }
    }
    
    private func configurePhysics(body: SKPhysicsBody, categoryBitMask: UInt32, contactTestBitMask: UInt32){
        body.isDynamic = false
        body.affectedByGravity = false
        body.categoryBitMask = categoryBitMask
        body.contactTestBitMask = contactTestBitMask
        body.collisionBitMask = 0
    }
}
