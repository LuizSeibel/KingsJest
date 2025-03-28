//
//  Lava.swift
//  KingsJest
//
//  Created by Willys Oliveira on 28/03/25.
//

import SpriteKit

class Lava {
    
    var nodes: [SKSpriteNode] = []
    
    var lava: SKSpriteNode?
    
    var moveLava: Bool = false
    
    let scene: SKScene
    
    init(scene: SKScene) {
        self.scene = scene
        
        for node in scene.children{
            
            if node.name == "cena2Lava"{
                if let lavaNode = node as? SKSpriteNode {
                    setupPhysics(for: lavaNode)
                    nodes.append(lavaNode)
                }
            }
            
            if node.name == "lava"{
                if let lavaNode = node as? SKSpriteNode {
                    setupPhysics(for: lavaNode)
                    self.lava = lavaNode
                }
            }
        }
    }
    
    func move() {
        guard self.lava != nil else { return }
        subirLavaAteOFim()
    }
    
    private func setupPhysics(for lavaNode: SKSpriteNode) {
        lavaNode.physicsBody = SKPhysicsBody(texture: lavaNode.texture!, size: lavaNode.size)
        lavaNode.physicsBody?.isDynamic = false
        lavaNode.physicsBody?.categoryBitMask = 2
        lavaNode.physicsBody?.contactTestBitMask = 1
        lavaNode.physicsBody?.collisionBitMask = 0
    }
    
    func subirLavaAteOFim() {
        guard let lava = self.lava else { return }

        let alturaDaLava = lava.frame.size.height

        let posicaoFinalY = self.scene.size.height + alturaDaLava * 1.8

        let moveAction = SKAction.moveTo(y: posicaoFinalY, duration: 20.0)

        let sequence = SKAction.sequence([moveAction])

        lava.run(sequence)
    }
}
