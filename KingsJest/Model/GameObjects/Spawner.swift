//
//  spawner.swift
//  KingsJest
//
//  Created by Luiz Seibel on 09/04/25.
//

import SpriteKit

class Spawner {
    
    var node: SKNode!
    var scene: SKScene!

    init(scene: SKScene, node: SKNode) {
        self.scene = scene
        self.node = node
    }
    
    func spawn() {
        let lava = LavaNode()
        
        let newY = node.position.y
        let newX = CGFloat.random(in: -300...300)
        
        lava.node.position = CGPoint(x: newX, y: newY)
        
        scene.addChild(lava.node)
        
        let randomVector = CGVector(dx: CGFloat.random(in: -4...4), dy: CGFloat.random(in: 10...14))
        
        let force = randomVector
        lava.node.physicsBody?.applyImpulse(force)
    }
}
