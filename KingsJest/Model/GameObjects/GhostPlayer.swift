//
//  GhostPlayer.swift
//  KingsJest
//
//  Created by Luiz Seibel on 02/04/25.
//

import Foundation
import SpriteKit

class GhostPlayer {
    let node: SKSpriteNode

    init(position: CGPoint) {
        let texture = SKTexture(imageNamed: "RUN000")
        self.node = SKSpriteNode(texture: texture, size: CGSize(width: 96, height: 84))
        self.node.position = position
        self.node.zPosition = 4
        
        // Deixa mais escuro e com opacidade
        self.node.color = .green
        self.node.colorBlendFactor = 0.5
        self.node.alpha = 0.7
    }

    func updateTexture(for velocity: CGVector) {
        if abs(velocity.dx) > 5 {
            let runFrames = (0..<8).map { SKTexture(imageNamed: String(format: "RUN%03d", $0)) }
            let runAction = SKAction.repeatForever(SKAction.animate(with: runFrames, timePerFrame: 0.1))
            node.run(runAction, withKey: "run")
            node.xScale = velocity.dx < 0 ? -1 : 1
        } else {
            node.removeAction(forKey: "run")
            node.texture = SKTexture(imageNamed: "idle000")
        }
    }
}
