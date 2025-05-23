//
//  Tomato.swift
//  KingsJest
//
//  Created by Luiz Seibel on 22/05/25.
//

import SpriteKit

class TomatoNode: SKShapeNode {
    var hasContacted = false
    
    init(position: CGPoint, scale: CGFloat, angle: CGFloat) {
        super.init()
        
        let ellipse = CGRect(x: -40, y: -30, width: 80, height: 60)
        self.path = CGPath(ellipseIn: ellipse, transform: nil)
        self.position = position
        self.fillColor = .red
        self.strokeColor = .clear
        self.zPosition = 100
        self.setScale(scale)
        
        self.zRotation = angle
        
        // Física inicial desligada
        self.physicsBody = SKPhysicsBody(rectangleOf: self.frame.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = 0
        self.physicsBody?.affectedByGravity = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
